require 'active_support'
require 'active_support/core_ext'
require 'erb'
require 'rack'
require 'byebug'
require_relative './session'

class ControllerBase
  attr_reader :req, :res, :params

  # Setup the controller
  def initialize(req, res, params = {})
    @req, @res, @params = req, res, params
    @already_built_response = false
  end

  # Helper method to alias @already_built_response
  def already_built_response?
    @already_built_response
  end

  # Set the response status code and header
  def redirect_to(url)
    raise 'Double render error' if already_built_response?
    @res.set_header('Location', url)
    @res.status = 302   #@res[]=
    session.store_session(@res)
    @already_built_response = true
  end

  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, content_type)
    raise 'Double render error' if already_built_response?
    @res['Content-Type'] = content_type
    @res.write(content)
    session.store_session(@res)
    @already_built_response = true
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    #file = File.dirname("views/#{self.class.to_s.underscore}/#{template_name}.html.erb") #.join
    file = File.join(File.dirname(__FILE__),"..","views", self.class.to_s.underscore, "#{template_name}.html.erb")
    content = File.read(file)
    template = ERB.new(content).result(binding)
    render_content(template, 'text/html')
  end

  # method exposing a `Session` object
  def session
    @session ||= Session.new(@req)
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
      # self.send(name)
      self.try(name)
      render(name) unless already_built_response?
  end
end

