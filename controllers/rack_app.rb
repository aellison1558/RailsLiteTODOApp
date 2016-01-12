require 'rack'

app = Proc.new do |env|
  req = Rack::Request.new(env)
  res = Rack::Response.new


  res['content-type'] = 'text/html'
  res.write(req.url)
  res.finish
end

Rack::Server.start(
  app: app,
  Port: 3000
)
