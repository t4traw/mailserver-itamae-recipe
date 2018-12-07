USER_NAME = node[:user][:name]
PASSWORD = node[:user][:password]
WHEEL_ID = "10"

user USER_NAME do
  password PASSWORD
end

user USER_NAME do
  gid WHEEL_ID
end

remote_file '/etc/sudoers.d/user' do
  source "./files/user"
end
