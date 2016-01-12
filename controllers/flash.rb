require 'json'

class Flash

  def initialize(req)
    @flash_hash = {}
    @flash_now_hash = {}
    @current_flash = req.cookies['flash'] ? JSON.parse(req.cookies['flash']) : {}
  end

  def [](key)
    key_sym = key.to_s
    result = []
    result << @flash_now_hash[key] if @flash_now_hash[key]
    result << @current_flash[key_sym] if @current_flash[key_sym]
    if result.length <= 0
      nil
    elsif result.length == 1
      result.first
    else
      result
    end
  end

  def []=(key, val)
    @flash_hash[key] = val
  end

  def now
    @flash_now_hash
  end

  def store_flash(res)
    res.set_cookie('flash', {path: '/', value: @flash_hash.to_json})
  end


end
