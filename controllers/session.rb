require 'json'

class Session
  def initialize(req)
    @session_hash = req.cookies['_rails_lite_app'] ? JSON.parse(req.cookies['_rails_lite_app']) : {}
  end

  def [](key)
    @session_hash[key]
  end

  def []=(key, val)
    @session_hash[key] = val
  end

  def store_session(res)
    res.set_cookie('_rails_lite_app', {path: '/', value: @session_hash.to_json})
  end
end
