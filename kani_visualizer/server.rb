require 'webrick'
require 'json'

# Webrick（HTTPサーバ）にマウントするサーブレットの共通クラス
class BaseServlet < WEBrick::HTTPServlet::AbstractServlet

  private

  # クエリパラメータのバリデーション
  def validate(query, keys)
    result = true
    keys.each do |key|
      result = false unless query.has_key?(key.to_s)
    end
    return result
  end

  # 捜査対象キャラクタをクエリパラメータから取得する
  def parse_target(query)
    if query.has_key?("target")
      Object.const_get(query["target"])
    else
      Kani1
    end
  end

  # HTTPクライアントへの成功応答を作成する
  def succeeded(response)
    response.status = 200
    response['Content-Type'] = 'text/html'
    response.body = '<html><body>done.</body></html>'
  end

  # HTTPクライアントへの失敗応答を作成する
  def failed(response)
    response.status = 400
    response['Content-Type'] = 'text/html'
    response.body = '<html><body>validation failed.</body></html>'
  end
end

# キャラクタの位置情報操作用サーブレット
class PositionServlet < BaseServlet
  def do_GET(request, response)
    query = request.query
    target = parse_target(query)
    if validate(query, [:op, :x, :y])
      case query["op"]
      when "abs"
        target.instance.set_pos(query["x"].to_i, query["y"].to_i)
      when "diff"
        target.instance.add_pos(query["x"].to_i, query["y"].to_i)
      end
      succeeded(response)
    else
      failed(response)
    end
  end
end

# キャラクタの角度情報操作用サーブレット
class AngleServlet < BaseServlet
  def do_GET(request, response)
    query = request.query
    target = parse_target(query)
    if validate(query, [:op, :value])
      case query["op"]
      when "abs"
        target.instance.set_angle(query["value"].to_i)
      when "diff"
        target.instance.add_angle(query["value"].to_i)
      end
      succeeded(response)
    else
      failed(response)
    end
  end
end

# キャラクタの表示／非表示制御用サーブレット
class VisibleServlet < BaseServlet
  def do_GET(request, response)
    query = request.query
    target = parse_target(query)
    if validate(query, [:value])
      target.instance.set_visible(query["value"].to_s == "true")
      succeeded(response)
    else
      failed(response)
    end
  end
end

# HTTPサーバクラス
class Server
  # コンストラクタ
  def initialize
    # HTTPサーバの設定情報
    @server_config = {
      Port: 3000,
      DocumentRoot: File.expand_path('./public'),
    }
    # HTTPサーバオブジェクトの生成（Webrick使用）
    @server = WEBrick::HTTPServer.new(@server_config)

    # エンドポイントのマウント
    @server.mount('/position', PositionServlet)
    @server.mount('/angle', AngleServlet)
    @server.mount('/visible', VisibleServlet)

    # アプリケーション終了時の処理（サーバ停止）
    trap('INT') { @server.shutdown }
  end

  # サーバ起動
  def run
    # 別スレッドを立ててそこでHTTPサーバを動かす。
    # NOTE: メインウィンドウと同じスレッドで起動すると処理が進まなくなってしまうため。
    Thread.new do
      @server.start
    end
  end
end