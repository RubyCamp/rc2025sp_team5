require 'gosu'
require 'net/http'
require 'uri'

# ボタン表示用クラス
class Button
  # コンストラクタ
  # NOTE: コンストラクタにブロックを取り、ボタンがクリックされた際に実行する挙動を保持しておく。
  def initialize(x, y, image, &block)
    @x, @y, @image = x, y, image
    @block = block
  end

  # 1フレーム分の更新処理
  # 引数（mx, my）は呼び出し元から渡されるマウス座標を前提とする。
  def update(mx, my)
    # 当該フレームにおいてマウスクリックを受けているか判定し、受けていない場合は何もせずメソッドを抜ける。
    return unless is_clicked?(mx, my)

    # NOTE: ここに処理が来るということは当該フレームにおいて自身（ボタン）がマウスクリックを受けたということになる。
    # このタイミング（自分がマウスクリックを受けた）で、保存しておいた「クリックされた際に実行するコード塊」に「実行せよ」との命令を伝え、処理を実行する。
    @block.call
  end

  # 1フレーム分の描画処理
  def draw
    @image.draw(@x, @y, 100)
  end

  private

  def is_clicked?(mx, my)
    if Gosu.button_down?(Gosu::MsLeft)
      (@x..(@x + @image.width)).include?(mx) && (@y..(@y + @image.height)).include?(my)
    end
  end
end


# Visualizerアプリのテスト用クライアント本体
class MainWindow < Gosu::Window
  # 各種定数定義
  WIDTH = 800         # ウィンドウ幅
  HEIGHT = 600        # ウィンドウ高さ
  FULL_SCREEN = false # フルスクリーン化フラグ（本アプリでは無効化する）

  # テスト対象Visualizerの基本URL
  BASE_URL = "http://localhost:3000"

  # コンストラクタ
  def initialize
    super WIDTH, HEIGHT, FULL_SCREEN
    self.caption = 'Kani Visualizer'

    @font = Gosu::Font.new(32, name: "DelaGothicOne-Regular.ttf")  # テキスト描画に使用するフォント
    @background = Gosu::Image.new("images/test/background.png")    # ウィンドウの背景画像
    left_arrow = Gosu::Image.new("images/test/left_arrow.png")     # 操作ボタン画像（左矢印）
    right_arrow = Gosu::Image.new("images/test/right_arrow.png")   # 操作ボタン画像（右矢印）
    up_arrow = Gosu::Image.new("images/test/up_arrow.png")         # 操作ボタン画像（上矢印）
    down_arrow = Gosu::Image.new("images/test/down_arrow.png")     # 操作ボタン画像（下矢印）

    # 操作ボタンオブジェクトをまとめて処理するための入れ物を作成
    @buttons = []

    # 蟹ロボ左移動ボタン生成
    @buttons << Button.new(20, 208, left_arrow) do
      Net::HTTP.get(URI.parse("#{BASE_URL}/position?op=diff&x=-1&y=0"))
      puts "Position(x) decrement"
    end

    # 蟹ロボ右移動ボタン生成
    @buttons << Button.new(168, 208, right_arrow) do
      Net::HTTP.get(URI.parse("#{BASE_URL}/position?op=diff&x=1&y=0"))
      puts "Position(x) increment"
    end

    # 蟹ロボ上移動ボタン生成
    @buttons << Button.new(94, 64, up_arrow) do
      Net::HTTP.get(URI.parse("#{BASE_URL}/position?op=diff&x=0&y=-1"))
      puts "Position(y) decrement"
    end

    # 蟹ロボ下移動ボタン生成
    @buttons << Button.new(94, 348, down_arrow) do
      Net::HTTP.get(URI.parse("#{BASE_URL}/position?op=diff&x=0&y=1"))
      puts "Position(y) increment"
    end

    # 蟹ロボ左回転ボタン生成
    @buttons << Button.new(420, 64, left_arrow) do
      Net::HTTP.get(URI.parse("#{BASE_URL}/angle?op=diff&value=-10"))
      puts "Angle(x) decrement"
    end

    # 蟹ロボ右回転ボタン生成
    @buttons << Button.new(568, 64, right_arrow) do
      Net::HTTP.get(URI.parse("#{BASE_URL}/angle?op=diff&value=10"))
      puts "Angle(x) increment"
    end
  end

  # 1フレーム分の更新処理
  def update
    exit if Gosu.button_down?(Gosu::KB_ESCAPE) # ESCキー押下を検知した場合はアプリを終了する。

    # ボタン群の一つ一つに対し、1フレーム分の更新処理の実施を要求する。
    # その際、Gosu::Windowクラスが提供するマウスの現在座標を引き渡すことで、当該ボタンがマウスクリックを受けたかどうかの判定をさせる。
    @buttons.each do |btn|
      btn.update(mouse_x, mouse_y)
    end
  end

  # 1フレーム分の描画処理
  def draw
    # 背景及びテキストの表示
    @background.draw(0, 0, 0)
    draw_text("Kani Position", 20, 20)
    draw_text("Kani Angle", 420, 20)

    # 全てのボタン群を画面に表示させる
    @buttons.each do |btn|
      btn.draw
    end
  end

  private

  # 画面の指定位置にテキストを描画する
  def draw_text(text, pos_x, pos_y)
    @font.draw_text(text, pos_x, pos_y, 100, 1.0, 1.0, 0xff_ffffff)
  end

end

# テスト用クライアントアプリ起動
window = MainWindow.new
window.show
