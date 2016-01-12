require_relative 'controller_base'

class ExceptionHandler
  attr_reader :app

  def initialize(app)
    @app = app
  end

  def call(env)
    @req = Rack::Request.new(env)
    @res = Rack::Response.new
    begin
      app.call(env)
    rescue => exception
      print "Rescued!"
      @params = {exception: exception, preview: error_lines(exception)}
      render
      @res.finish
    end
  end

  def error_lines(exception)
    file_path_array = exception.backtrace.first.split(":")
    file_array = File.readlines(file_path_array.first)
    error_line = file_path_array[1].to_i - 1
    file_array[error_line] = "<b>#{file_array[error_line]}  <font color='red'><<< THIS IS WHERE THE ERROR IS</b></font>"
    result = ""
    if error_line >= 5 && (error_line + 5 < file_array.length)
      i = error_line - 5
      while i < error_line + 5
        result = result + (i + 1).to_s + " " + file_array[i] + "<br>"
        i += 1
      end
    elsif error_line < 5
      i = 0
      while i < error_line + 5
        result = result + (i + 1).to_s + file_array[i] + "<br>"
        i += 1
      end
    else
      i = error_line - 5
      while i < file_array.length
        result = result + (i + 1).to_s + file_array[i] + "<br>"
        i += 1
      end
    end
    result.html_safe
  end

  def render
    file = File.read("views/shared/exception_handling.html.erb")
    erb_template = ERB.new(file)
    render_content(erb_template.result(binding), 'text/html')
  end

  def render_content(content, content_type)
    @res.write(content)
    @res['content-type'] = content_type
  end
end
