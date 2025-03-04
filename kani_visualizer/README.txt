# 蟹ロボVisualizer・サンプル
本アプリは蟹ロボから送信される情報に基づいて、ウィンドウ上にその情報を視覚化して表示する「Visualizer」のサンプルです。

## 前提
以下の構成を前提とします。

* Ruby 3.2以上
   * Gosu/Ruby導入済み（ref: https://github.com/gosu/gosu/wiki/ ）

## 使い方
本アプリのディレクトリ（kani_visualizer）をカレントディレクトリとし、以下のコマンドでVisualizerを起動します。

```
ruby main.rb
```

デフォルトでは、ポート番号3000にてWebrick（HTTPサーバ）が立ち上がり、その後自動的にVisualizerのウィンドウが開きます。
起動時のログの例を以下に示します。

```
C:\rubycamp2025\src\kani_visualizer>ruby main.rb
[2025-02-10 10:20:44] INFO  WEBrick 1.8.1
[2025-02-10 10:20:44] INFO  ruby 3.2.3 (2024-01-18) [i386-mingw32]
[2025-02-10 10:20:45] INFO  WEBrick::HTTPServer#start: pid=32256 port=3000
```

起動後は、3000番ポートに対してHTTP通信を行うことで、Visualizer上の蟹ロボキャラクタを操作することができます。

## API仕様
APIの仕様を簡単に説明します。

APIはHTTPのGETリクエストでVisualizer上のHTTPサーバに要求を投げることで実行します。
当該URLを仮に「http://localhost:3000」とすると、例えば

```
GET http://localhost:3000/position?op=abs&x=100&y=200&target=Kani1
```

のような形式で呼び出します。
上記例の場合、

* API名 => /position
* パラーメタ
   * op => 「abs」
   * x => 「100」
   * y => 「200」
   * target => 「Kani1」

のようになります。
※ サーバクラスの詳細は「server.rb」に記載されています。

以下、サンプルに定義したAPIの簡単な説明を記載します。

### /position
Visualizer上のキャラクタの座標を変更します。
パラメータはそれぞれ以下のようになります。

* target: 捜査対象のキャラクタのクラス名を指定します。省略時は「Kani1」になります。
* op: 操作種別を意味します。
   * 「abs」: 座標「x」「y」をウィンドウに対する絶対座標として更新します。
   * 「diff」: 座標「x」「y」を現在のキャラクタ座標に対する差分として更新します。
* x: X座標値
* y: Y座標値

### /angle
Visualizer上のキャラクタの回転角を変更します。
パラメータはそれぞれ以下のようになります。

* target: 捜査対象のキャラクタのクラス名を指定します。省略時は「Kani1」になります。
* op: 操作種別を意味します。
   * 「abs」: 角度「value」をキャラクタに対する絶対座標として更新します。
   * 「diff」: 角度「value」を現在のキャラクタの角度に対する差分として更新します。
* value: 角度値

### /visible
Visualizer上のキャラクタの表示・非表示を変更します。
パラメータはそれぞれ以下のようになります。

* target: 捜査対象のキャラクタのクラス名を指定します。省略時は「Kani1」になります。
* value: 真偽値（の文字列表現）
   * 「true」: 表示する
   * 「false」: 表示しない


## テスト用アプリ
上記HTTPサーバ（Webrick）に対して、実際の蟹ロボからHTTP通信で情報の授受を行うわけですが、蟹ロボ無しでローカルテストをしたい場合に備え、テスト用のクライアントアプリを同梱しています。
使い方は、Visualizerのディレクトリをカレントとして、

```
ruby test_kani.rb
```

で実行できます。
デフォルトでは「http://localhost:3000」にて待機するVisualizerのHTTPサーバに対して、Kani1キャラクタの座標更新（diffモード）と角度更新（diffモード）がテストできるようになっています。
URLを変更したい場合は「MainWindow::BASE_URL」定数の値を変更してください。