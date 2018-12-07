# mailserver itamae recipe

メールサーバーを建てる時に使ったitamaeのレシピです。

## 構成

  - CentOS7
  - Apache
  - Postfix
  - Dovecot
  - Let's Encrypt

## Require

  - ruby 2.5.0

## 準備

```
$ git clone git@github.com:t4traw/mailserver-itamae-recipe.git
$ bundle install
```

ユーザーのパスワードを送信するのに暗号化が必要です。下記コマンドを使えば、対話式で暗号化されたパスワードを生成できます。

```
$ mkunixcrypt -s "salt"

#> Enter password: YOUR_PASSWORD
#> Verify password: YOUR_PASSWORD
```

ここで生成された`$6$salt$0aisk/8Xgl...`の1行をnode.ymlのuser>passwordにコピペします。

次にsshキーの生成し、公開鍵をnode.ymlのssh>keyにコピペします

```
# 対話式でキーを生成する
$ ssh-keygen -t rsa -C 'admin@example.com'

# 権限を変更する 
$ chmod 600 YOUR_SSH_KEY_NAME

# 生成したキーの中身をコピー
pbcopy < ~/.ssh/YOUR_SSH_KEY_NAME.pub
```

## プロビジョニング

git cloneして、`bundle install`し、itamaeコマンドを実行します。

```
$ itamae ssh -h YOUR_HOST_IP -u root -y node.yml recipes.rb
```

すると、サーバーのrootパスワードを聞かれるので、rootパスワードを入力します。

あとは自動でプロビジョニングが実行されます。

## メールアカウントの作り方

```
# rootで実行するので、suしておきます
$ su

# ユーザー作成
$ useradd -s /sbin/nologin YOUR_USER_NAME
$ echo "YOUR_PASSWORD" | passwd --stdin YOUR_USER_NAME
$ echo "YOUR_PASSWORD" | saslpasswd2 -p -u YOUR_DOMAIN -c YOUR_USER_NAME

# ユーザーの確認
$ sasldblistusers2

# パスワード変更
$ echo "YOUR_PASSWORD" | saslpasswd2 -p -u YOUR_DOMAIN YOUR_USER_NAME

# ユーザーの削除
$ saslpasswd2 -u YOUR_DOMAIN -d YOUR_USER_NAME
```

## メールを転送する方法

aaa@example.comのメールをbbb@example.comとccc@example.comに転送する場合は以下のように/etc/aliasesに追加します。

`vim /etc/aliases`で直接追加してもかまいません。

```
$ echo "aaa: bbb,ccc" >> /etc/aliases
$ postalias /etc/aliases && newaliases
```

別のメールアドレスに転送したいなどの場合は、

```
$ echo "aaa: bbb@foobar.com" >> /etc/aliases
$ postalias /etc/aliases && newaliases
```

といった記述をします。

転送元にはメールが残らない仕様になっています。

もしも転送元のメールを残したいといった場合は`.forward`というファイルを生成してなどしなくてはいけない(参考: [Postfix+Dovecotによるメールサーバーの構築 - Akionux-wiki](http://ja.akionux.net/wiki/index.php/Postfix%2BDovecot%E3%81%AB%E3%82%88%E3%82%8B%E3%83%A1%E3%83%BC%E3%83%AB%E3%82%B5%E3%83%BC%E3%83%90%E3%83%BC%E3%81%AE%E6%A7%8B%E7%AF%89))。
