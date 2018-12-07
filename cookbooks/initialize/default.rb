package 'git'
package 'curl'
package 'wget'
package 'openssh-clients'
package 'openssl'
package 'epel-release'

execute "update yum repo" do
  user "root"
  command "yum -y update"
end