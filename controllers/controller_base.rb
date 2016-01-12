require 'active_support'
require 'active_support/core_ext'
require 'erb'
require 'json'
require_relative './session'
require_relative './flash'


class ControllerBase
  attr_reader :req, :res, :params

  def initialize(req, res, route_params = {})
    @req = req
    @res = res
    @params = req.params.merge(route_params)
    @auth_token = flash["authenticity_token"] || SecureRandom.urlsafe_base64
  end

  def already_built_response?
    @already_built_response
  end

  def redirect_to(url)
    raise InvalidAuthenticityToken unless verify_authenticity?
    raise "Cannot render twice!" if already_built_response?

    @res.status = 302
    @res['location'] = url

    session.store_session(@res)
    flash.store_flash(@res)
    @already_built_response = true
  end

  def render_content(content, content_type)
    raise InvalidAuthenticityToken unless verify_authenticity?
    raise "Cannot render twice!" if already_built_response?

    @res.write(content)
    @res['content-type'] = content_type

    session.store_session(@res)
    flash.store_flash(@res)
    @already_built_response = true
  end

  def render(template_name)
    raise InvalidAuthenticityToken unless verify_authenticity?

    controller_name = self.class.name.underscore
    file = File.read("views/#{controller_name}/#{template_name}.html.erb")
    erb_template = ERB.new(file)
    render_content(erb_template.result(binding), 'text/html')
  end

  def session
    @session ||= Session.new(@req)
  end

  def flash
    @flash ||= Flash.new(@req)
  end

  def invoke_action(name)
    self.send(name)
    render(name) unless already_built_response?
  end

  def form_authenticity_token
    flash['authenticity_token'] = @auth_token
    @auth_token
  end

  def verify_authenticity?
    return true if @req.request_method == "GET"
    flash["authenticity_token"] == @auth_token
  end
end

class InvalidAuthenticityToken < StandardError
end
