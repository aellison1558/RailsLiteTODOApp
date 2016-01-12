require_relative('./controller_base')
require_relative('../models/todo_list.rb')
require_relative('../models/todo_item.rb')
require_relative('../models/detail.rb')

class TodoListsController < ControllerBase
  def index
    @lists = TodoList.all
  end

  def create
    @list = TodoList.new(params["list"])
    if @list.save
      flash[:notice] = "Saved Todo List successfully"
      redirect_to '/todos'
    else
      flash.now[:errors] = "Something went wrong"
      render :new
    end
  end

  def new
    @list = TodoList.new
  end

  def show
    @list = TodoList.find(params['id'].to_i)
    @items = @list.items
  end
end
