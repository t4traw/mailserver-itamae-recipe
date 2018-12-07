package 'dovecot'

HOSTNAME = "mail.#{node[:domain]}"

file "/etc/dovecot/conf.d/10-mail.conf" do
  action :edit
  block do |content|
    content.gsub!("#mail_location =", "mail_location = maildir:~/Maildir")
  end
end

file "/etc/dovecot/conf.d/10-ssl.conf" do
  action :edit
  block do |content|
    content.gsub!('ssl = required', 'ssl = yes')
    content.gsub!(/ssl_cert = .*$/, "ssl_cert = </etc/letsencrypt/live/#{HOSTNAME}/fullchain.pem")
    content.gsub!(/ssl_key = .*$/, "ssl_key = </etc/letsencrypt/live/#{HOSTNAME}/privkey.pem")
  end
end

file "delete default 10-master.conf" do
  path "/etc/dovecot/conf.d/10-master.conf"
  action :delete
end

template "/etc/dovecot/conf.d/10-master.conf"

file "/etc/dovecot/dovecot.conf" do
  action :edit
  block do |content|
    content.gsub!("#protocols = imap pop3 lmtp", "protocols = imap")
  end
end

execute "add mail server ports" do
  user "root"
  cmd = [
    'firewall-cmd --add-service=smtp --permanent --zone=public',
    'firewall-cmd --add-service=smtps --permanent --zone=public',
    'firewall-cmd --add-service=imaps --permanent --zone=public',
    'firewall-cmd --reload'
  ]
  command cmd.join('&&')
end

service 'dovecot' do
  action [:start, :enable]
end

service 'postfix' do
  action [:start, :enable]
end

