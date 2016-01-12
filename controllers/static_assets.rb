class StaticAssets
  attr_reader :app

  def initialize(app)
    @app = app
  end

  def call(env)
    req = Rack::Request.new(env)
    res = Rack::Response.new
    if path_matched?(req)
      res.write(File.read(req.path[1..-1]))
      res['content-type'] = type(req) if type(req)
      res.finish
    else
      app.call(env)
    end
  end

  def path_matched?(req)
    req.path.match(/^\/public/)
  end

  def file_extension(req)
    req.path.split(".").last
  end

  def type(req)
    case file_extension(req)
    when 'jpg' || 'png' || 'gif'
      "image/#{file_extension(req)}"
    when 'txt'
      "text/plain"
    when 'html'
      "text/html"
    when 'js'
      "application/javascript"
    when 'css'
      "text/css"
    else
      nil
    end
  end
end
