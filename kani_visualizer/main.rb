require 'gosu'

require_relative 'server'
require_relative 'characters'

# ゲームのメインウィンドウ（メインループ）用クラス
class MainWindow < Gosu::Window
  # 各種定数定義
  WIDTH = 600
  HEIGHT = 800
  FULL_SCREEN = false

  # コンストラクタ
  def initialize
    super WIDTH, HEIGHT, FULL_SCREEN
    self.caption = 'Kani Visualizer'
    # 背景設定・表示
    @background = Gosu::Image.new("images/field.png")
    @angle = -90
    @kani1 = Kani1.instance
    # visibleではオブジェクトの表示非表示を設定
    @kani1.visible = true
    @kani1.set_pos(690, 467)
    @kani1.set_angle(0)
    @ball = Ball.instance
    @ball.visible = false


    @characters = [@kani1, @ball]
  end

  # 1フレーム分の更新処理
  def update
    exit if Gosu.button_down?(Gosu::KB_ESCAPE)
  end

  # 1フレーム分の描画処理
  def draw
    @background.draw_rot(300,400,0,@angle)
    @characters.each do |character|
      character.draw if character.visible
    end
  end
end

# Webrickサーバ開始
Server.new.run

# メインウィンドウ表示
window = MainWindow.new
window.show

GET http://192.168.6.25:3000/position?op=abs&x=500&y=100
GET http://192.168.6.25:3000/angle?op=abs&value=180
