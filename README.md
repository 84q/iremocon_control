# IremoconControl

株式会社Glamoから発売されている学習リモコンiRemoconをRubyから操作するgemです。
赤外線送信、赤外線登録、タイマ登録など一通りの機能があります。

## Installation

Add this line to your application's Gemfile:

    gem 'iremocon_control'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install iremocon_control

## Usage

### Ruby上からIRemoconを操作する場合
モジュールをロードします。

    require 'iremocon_control'

IRemoconオブジェクトを作成します。

    iremocon = IRemoconControl::IRemocon.new '192.168.0.100'

IRemoconオブジェクトに対してコマンドを発行します。

    # リモコンNo.1として登録した赤外線を送信
    iremocon.is 1

### シェル上からIRemoconを操作する場合
#### 基本的な使い方
ホスト名とリモコン番号を指定して赤外線を送信

    $ iremocon -h 192.168.0.100 1

#### 設定ファイルの読み込み
設定ファイルにiRemoconのホスト名(、ポート番号)を指定することができます。
設定はYAML形式で指定します。

    $ cat iremoconrc
    host: 192.168.0.100
    $ iremocon -f iremoconrc 1

~/.iremoconrcはデフォルトで読み込まれます。

    $ cat ~/.iremoconrc
    host: 192.168.0.100
    $ iremocon 1

#### is(赤外線送信)以外のコマンドの利用
iremoconとの接続の確認

    $ iremocon --au

iremoconの現在時刻設定(引数 : 設定する時刻のUnixTime)

    $ iremocon --ts `date '+%s'`

iremoconの現在時刻取得

    $ iremocon --tg

iremoconのバージョン番号取得

    $ iremocon --vr

## Contributing

1. Fork it ( https://github.com/[my-github-username]/iremocon_control/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
