require 'singleton'

# 視覚化対象の共通クラス
class Character
  # シングルトンクラス化
  # ref: https://docs.ruby-lang.org/ja/latest/class/Singleton.html
  include Singleton

  # インスタンス外から設定変更を許可するアクセサ定義
  attr_accessor :x, :y, :angle, :image, :visible

  # コンストラクタ
  def initialize
    set_image
    @visible = false
    @x = 0
    @y = 0
    @angle = 0
  end

  # キャラクタの座標を上書きする
  def set_pos(x, y)
    @x, @y = x, y
  end

  # キャラクタの座標を増減させる
  def add_pos(dx = 0, dy = 0)
    @x += dx
    @y += dy
  end

  # キャラクタの回転角を上書きする
  def set_angle(angle)
    @angle = angle
  end

  # キャラクタの回転角を増減させる
  def add_angle(da)
    @angle += da
  end

  # キャラクタ画像を画面上に表示するかどうかを変更する
  def set_visible(visible)
    @visible = visible
  end

  # キャラクタ画像をウィンドウに描画
  def draw
    @image.draw_rot(@x, @y, 0, @angle)
  end

  private

  # キャラクタ画像を設定する
  # NOTE: 継承先においてオーバーライドし、サブクラス毎に固有の画像を設定できるようにしている。
  def set_image
    raise "override me"
  end
end

# 視覚化対象クラス（蟹ロボ1台目）
# ※ 本サンプルでは１台のみ表示するためKani2は作らない。
class Kani1 < Character
  private

  # 蟹ロボの固有画像を設定するようオーバーライド
  def set_image
    @image = Gosu::Image.new("images/kani.png")
  end
end

# 視覚化対象クラス（ボール）
class Ball < Character
  private

  # ボールの固有画像を設定するようオーバーライド
  def set_image
    @image = Gosu::Image.new("images/ball.png")
  end
end