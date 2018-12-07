package 'postfix'

HOSTNAME = "mail.#{node[:domain]}"

file "/etc/postfix/main.cf" do
  action :edit
  block do |content|
    # メールサーバのホスト名(FQDN)を指定
    content.gsub!("#myhostname = host.domain.tld", "myhostname = #{HOSTNAME}")
    
    # メールサーバのドメイン名を指定
    content.gsub!("#mydomain = domain.tld", "mydomain = #{node[:domain]}")
    
    # メールアドレスを「ユーザ名@ドメイン名」の形式にする
    content.gsub!("#myorigin = $mydomain", "myorigin = $mydomain")
    
    # 全てのホストからメールを受信する
    content.gsub!(/^inet_interfaces\s=\s.*$/, "inet_interfaces = all")
    
    # 受信するドメイン宛のメールを指定する
    content.gsub!(/^mydestination.*?localhost$/, "mydestination = $myhostname, localhost.$mydomain, localhost, $mydomain")
    
    # メールの格納フォーマットの指定
    content.gsub!("#home_mailbox = Maildir/", "home_mailbox = Maildir/")
    
    # 不要な情報を公開しない
    content.gsub!("#smtpd_banner = $myhostname ESMTP $mail_name", "smtpd_banner = $myhostname ESMTP unknown")
    
    # --------------------------------------------------
    # 追加設定項目
    # --------------------------------------------------
    additional_option = []
    
    # SASL認証を有効化
    additional_option << "smtpd_sasl_auth_enable = yes"
    additional_option << "smtpd_sasl_local_domain = $myhostname"
    
    # 認証にDovecotを指定
    additional_option << "smtpd_sasl_type = dovecot"
    additional_option << "smtpd_sasl_path = private/auth"
    
    # 認証を通過したものはリレーを許可する（permit_sasl_authenticated）
    additional_option << "smtpd_recipient_restrictions = permit_mynetworks permit_sasl_authenticated reject_unauth_destination"
    
    # 受信メールサイズを10MBに制限
    additional_option << "message_size_limit = 10485760"

    # SSLで暗号化するため、TLSを有効化
    additional_option << "smtpd_use_tls = yes"

    # サーバ証明書と秘密鍵を指定(Let's encrypt)
    additional_option << "smtpd_tls_cert_file = /etc/letsencrypt/live/#{HOSTNAME}/fullchain.pem"
    additional_option << "smtpd_tls_key_file = /etc/letsencrypt/live/#{HOSTNAME}/privkey.pem"

    # 接続キャッシュファイルの指定
    additional_option << "smtpd_tls_session_cache_database = btree:/var/lib/postfix/smtpd_scache"

    # 存在しないユーザー宛メールの破棄
    additional_option << "local_recipient_maps ="
    additional_option << "luser_relay = unknown_user@localhost"

    content.concat << additional_option.join("\n")
  end
end

template "/etc/postfix/master.cf"

file "/etc/sasl2/smtpd.conf" do
  action :edit
  block do |content|
    content.gsub!("pwcheck_method: saslauthd", "pwcheck_method: auxprop")
  end
end

# Maildir形式で受信できるようにする
execute 'mkdir -p /etc/skel/Maildir/{new,cur,tmp}'
execute 'chmod -R 700 /etc/skel/Maildir'

# 存在しないユーザー宛のメールを破棄するための設定
execute 'echo unknown_user: /dev/null >> /etc/aliases'
execute 'newaliases'

service 'postfix' do
  action [:start, :enable]
end
