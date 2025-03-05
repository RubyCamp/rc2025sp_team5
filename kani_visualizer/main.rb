require 'gosu'

require_relative 'server'
require_relative 'characters'

# ゲームのメインウィンドウ（メインループ）用クラス
class MainWindow < Gosu::Window
  # 各種定数定義
  WIDTH = 840
  HEIGHT = 891
  FULL_SCREEN = false

  # コンストラクタ
  def initialize
    super WIDTH, HEIGHT, FULL_SCREEN
    self.caption = 'Kani Visualizer'
    # 背景設定・表示
    @background = Gosu::Image.new("images/field2.png")
    @back_x = 420
    @back_y = 445.5
    @angle = -90
    @kani1 = Kani1.instance
    # visibleではオブジェクトの表示非表示を設定
    @kani1.visible = true
    @kani1.set_pos(760, 100)
    @kani1.set_angle(180)
    @ball = Ball.instance
    @ball.visible = true
    @ball.set_pos(560,200)
    @characters = [@kani1, @ball]
  end

  # 1フレーム分の更新処理
  def update
    exit if Gosu.button_down?(Gosu::KB_ESCAPE)
  end

  # 1フレーム分の描画処理
  def draw
    @background.draw_rot(@back_x,@back_y,0,@angle)
    draw_vertical_lines
    draw_horizontal_lines
    @characters.each do |character|
      character.draw if character.visible
    end
  end
end


private 

def draw_vertical_lines # 横のマス目を描画
  spacing = width / 6.0
  5.times do |i|
    x = spacing * (i+1)
      draw_line(x, 0, Gosu::Color::BLACK, x, height, Gosu::Color::BLACK)
  end
end

def draw_horizontal_lines # 縦のマス目を描画
  spacing = width / 4.0
  3.times do |i|
    y = spacing * (i+1)
      draw_line(0, y, Gosu::Color::BLACK, width, y, Gosu::Color::BLACK)
  end
end


# Webrickサーバ開始
Server.new.run

# メインウィンドウ表示
window = MainWindow.new

window.show
