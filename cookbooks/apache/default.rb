package 'httpd'

file "/etc/httpd/conf/httpd.conf" do
  action :edit
  block do |content|
    content.gsub!(/#ServerName www.example.com:80/, "ServerName #{node[:domain]}:80")
  end
end

service 'httpd' do
  action [:enable, :start]
end