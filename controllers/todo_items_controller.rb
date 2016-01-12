require_relative('./controller_base')
require_relative('../models/todo_list.rb')
require_relative('../models/todo_item.rb')
require_relative('../models/detail.rb')

class TodoItemsController < ControllerBase

  def create
    @item = TodoItem.new(params["item"])
    @item.done = 'false'
    if @item.save
      flash[:notice] = "Saved Todo Item successfully"
      redirect_to ('/todos/' + @item.list_id.to_s)
    else
      flash.now[:errors] = "Something went wrong"
      render :new
    end
  end

  def new
    @item = TodoItem.new
    @lists = TodoList.all
  end

end
