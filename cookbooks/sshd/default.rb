USER_NAME = node[:user][:name]
PASSWORD = node[:user][:password]

directory "/home/#{USER_NAME}/.ssh" do
  owner USER_NAME
  group USER_NAME
  mode "700"
end

file "/home/#{USER_NAME}/.ssh/authorized_keys" do
  content node[:ssh][:key]
  owner USER_NAME
  group USER_NAME
  mode "600"
end

file "sshd_config" do
  path "/etc/ssh/sshd_config"
  action :edit
  block do |content|
    content.gsub!(/^.?Port .+$/, "Port #{node[:ssh][:port]}")
    content.gsub!(/^.?PermitRootLogin .+$/, "PermitRootLogin no")
    content.gsub!(/^PasswordAuthentication .+$/, "PasswordAuthentication no")
    content.gsub!(/^UsePAM .+$/, "UsePAM no")
  end
end

service "sshd" do
  subscribes :restart, "file[sshd_config]"
end
