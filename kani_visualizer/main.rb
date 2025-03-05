require 'gosu'
require 'net/http'

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
    @kani1.set_pos(0,0)
    @kani1.set_angle(180)
    @ball = Ball.instance
    @ball.visible = false
    @ball.set_pos(560,200)
    @characters = [@kani1, @ball]
    @path_points = [
      [760, 100], [760, 210], [140, 210], [140, 420], [700, 420], [700, 630], [420, 630],[420, 891]
    ] #　青線の座標

    @line_width = 5 # 線の太さを指定
  end

  # 1フレーム分の更新処理
  def update
    exit if Gosu.button_down?(Gosu::KB_ESCAPE)
    webPostPos
  end

  # 1フレーム分の描画処理
  def draw
    @background.draw_rot(@back_x,@back_y,0,@angle)
    draw_vertical_lines
    draw_horizontal_lines
    draw_path
    @characters.each do |character|
      character.draw if character.visible
    end
  end

  def draw_path
    @path_points.each_cons(2) do |(x1, y1), (x2, y2)|
      draw_thick_line(x1, y1, x2, y2, @line_width, Gosu::Color::BLUE)
    end
  end
  

  def draw_thick_line(x1, y1, x2, y2, width, color)
    angle = Math.atan2(y2 - y1, x2 - x1)
    offset_x = Math.cos(angle + Math::PI / 2) * width / 2
    offset_y = Math.sin(angle+ Math::PI / 2) * width / 2

    Gosu.draw_quad(
      x1 - offset_x, y1 - offset_y, color,
      x2 - offset_x, y2 - offset_y, color,
      x2 + offset_x, y2 + offset_y, color,
      x1 + offset_x, y1 + offset_y, color,
      0
    )
  end
end

def webPostPos # サーバにリクエストを送信、ここで座標関係を共有できるか？
  params = {op: "abs", x: 760, y: 100, angle:0, target:"Kani1"} 
  uri = URI.parse("http://192.168.6.25:3000/position")  # position~ から先の情報を指定
  uri.query = URI.encode_www_form(params)
  response = Net::HTTP.get_response(uri)
  

  response.code
  response.body
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




