service 'firewalld' do
  action [:start, :enable]
end

# 自分用のsshポートを開ける
execute "add my-ssh port" do
  user "root"
  command "firewall-cmd --permanent --add-port=#{node[:ssh][:port]}/tcp --zone=public"
end

# デフォルトのsshポートを閉じる
execute "remove default ssh port" do
  user "root"
  command "firewall-cmd --permanent --remove-service=ssh"
end

# webサーバー系のポートを開ける
execute "add web server ports" do
  user "root"
  cmd = [
    'firewall-cmd --add-port=80/tcp --permanent --zone=public',
    'firewall-cmd --add-port=443/tcp --permanent --zone=public'
  ]
  command cmd.join('&&')
end

# メールサーバー用のポートを開ける
execute "add mail server ports" do
  user "root"
  cmd = [
    'firewall-cmd --add-port=25/tcp --permanent --zone=public',
    'firewall-cmd --add-port=465/tcp --permanent --zone=public',
    'firewall-cmd --add-port=993/tcp --permanent --zone=public',
    'firewall-cmd --add-port=995/tcp --permanent --zone=public'
  ]
  command cmd.join('&&')
end

execute 'firewall-cmd --reload'

service 'firewalld' do
  action [:restart]
end
