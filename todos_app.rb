require 'rack'
require_relative './controllers/controller_base'
require_relative './controllers/router'
require_relative './controllers/static_assets'
require_relative './controllers/exception_handler'
require_relative './controllers/todo_lists_controller'
require_relative './controllers/todo_items_controller'
require_relative './controllers/details_controller'

router = Router.new
router.draw do
  get Regexp.new("^/$"), TodoListsController, :index
  get Regexp.new("^/todos$"), TodoListsController, :index
  get Regexp.new("^/todos/new$"), TodoListsController, :new
  get Regexp.new("^/todos/(?<id>\\d+)$"), TodoListsController, :show
  post Regexp.new("^/todos$"), TodoListsController, :create
  get Regexp.new("^/todos/(?<list_id>\\d+)/items/new$"), TodoItemsController, :new
  post Regexp.new("^/items$"), TodoItemsController, :create
  get Regexp.new("^/details/new$"), DetailsController, :new
  post Regexp.new("^/details$"), DetailsController, :create
end

my_app = Proc.new do |env|
  req = Rack::Request.new(env)
  res = Rack::Response.new
  router.run(req, res)
  res.finish
end

app = Rack::Builder.new do
  # use ExceptionHandler
  use StaticAssets
  run my_app
end.to_app

Rack::Server.start(
 app: app,
 Port: 3000
 )
