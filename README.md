[oiax RSpec/Capybara入門](https://www.oiax.jp/rails/rspec_capybara_primer.html)の個人勉強用リポジトリです

## 要件

* ruby 2.2.5
* mysql

## 使い方

```
$ git clone git@github.com:seak0503/sinope.git

$ cd sinope

$ bundle install
```

## 補足

### [ユーザー認証のテスト（3） -- スタブの活用](https://www.oiax.jp/rails/rspec_capybara_primer/signing_in3.html)

スタブの実装で `Customer.stub(:authenticate).and_return(Customer.new)` で定義されているところがあるが、rspec3の環境だと
エラーになる。

```
$ bin/rspec spec/features/login_and_logout_spec.rb

ログイン
  ユーザー認証成功 (FAILED - 1)
  ユーザー認証失敗 (FAILED - 2)

Failures:

  1) ログイン ユーザー認証成功
     Failure/Error: Customer.stub(:authenticate).and_return(FactoryGirl.create(:customer))
       Customer(id: integer, family_name: string, given_name: string, family_name_kana: string, given_name_kana: string, created_at: datetime, updated_at: datetime) does not implement: authenticate
     # ./spec/features/login_and_logout_spec.rb:5:in `block (2 levels) in <top (required)>'

  2) ログイン ユーザー認証失敗
     Failure/Error: Customer.stub(:authenticate)
       Customer(id: integer, family_name: string, given_name: string, family_name_kana: string, given_name_kana: string, created_at: datetime, updated_at: datetime) does not implement: authenticate
     # ./spec/features/login_and_logout_spec.rb:17:in `block (2 levels) in <top (required)>'

Deprecation Warnings:

Using `stub` from rspec-mocks' old `:should` syntax without explicitly enabling the syntax is deprecated. Use the new `:expect` syntax or explicitly enable `:should` instead. Called from /Users/shyamahira/git/sinope/spec/features/login_and_logout_spec.rb:5:in `block (2 levels) in <top (required)>'.


If you need more of the backtrace for any of these deprecations to
identify where to make the necessary changes, you can configure
`config.raise_errors_for_deprecations!`, and it will turn the
deprecation warnings into errors, giving you the full backtrace.

1 deprecation warning total

Finished in 0.03397 seconds (files took 8.37 seconds to load)
2 examples, 2 failures

Failed examples:
```

この場合、下記のように変更する必要がある

```
allow(Customer).to receive(:authenticate).and_return(FactoryGirl.create(:customer))
```

これでOKかと思いきや、下記のとおりエラーになってしまいます。

```
$ bin/rspec spec/features/login_and_logout_spec.rb

ログイン
  ユーザー認証成功 (FAILED - 1)
  ユーザー認証失敗 (FAILED - 2)

Failures:

  1) ログイン ユーザー認証成功
     Failure/Error: allow(Customer).to receive(:authenticate).and_return(FactoryGirl.create(:customer))
       Customer(id: integer, family_name: string, given_name: string, family_name_kana: string, given_name_kana: string, created_at: datetime, updated_at: datetime) does not implement: authenticate
     # ./spec/features/login_and_logout_spec.rb:6:in `block (2 levels) in <top (required)>'

  2) ログイン ユーザー認証失敗
     Failure/Error: allow(Customer).to receive(:authenticate)
       Customer(id: integer, family_name: string, given_name: string, family_name_kana: string, given_name_kana: string, created_at: datetime, updated_at: datetime) does not implement: authenticate
     # ./spec/features/login_and_logout_spec.rb:18:in `block (2 levels) in <top (required)>'

Finished in 0.11814 seconds (files took 8.91 seconds to load)
2 examples, 2 failures

Failed examples:

rspec ./spec/features/login_and_logout_spec.rb:4 # ログイン ユーザー認証成功
rspec ./spec/features/login_and_logout_spec.rb:16 # ログイン ユーザー認証失敗
```

`does not implement: authenticate`と怒っています。

原因としては存在しないメソッドはスタブできないようになった為のようだ。

そのため、下記のように空のメソッドを定義する必要がある。

* app/models/customer.rb

```
require 'nkf'

class Customer < ActiveRecord::Base

〜略〜

  def self.authenticate(username, password)
  end
end
```