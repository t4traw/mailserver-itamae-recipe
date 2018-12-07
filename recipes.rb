# 基本パッケージ、yumアップデート
include_recipe './cookbooks/initialize/default.rb'

# ログインユーザー追加
include_recipe './cookbooks/user/default.rb'

# rootでのssh禁止、ポートの変更
include_recipe './cookbooks/sshd/default.rb'

# ポート開放
include_recipe './cookbooks/firewalld/default.rb'

# SSL証明書取得。Apacheとか入れる前に実行する必要アリ
include_recipe './cookbooks/letsencrypt/default.rb'

# Apacheインストール
include_recipe './cookbooks/apache/default.rb'

# メールサーバーインストール
include_recipe './cookbooks/postfix/default.rb'
include_recipe './cookbooks/dovecot/default.rb'

execute "reboot" do
  user 'root'
  command 'reboot'
end
