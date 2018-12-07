package 'certbot'

HOSTNAME = "mail.#{node[:domain]}"

execute "certbot certonly -n --standalone -d #{HOSTNAME} -m #{node[:letsencrypt][:mail_address]} --agree-tos"

execute %(echo '00 04 * * 3 root /usr/bin/certbot renew --post-hook "systemctl restart postfix dovecot httpd"' > /etc/cron.d/letsencrypt)
