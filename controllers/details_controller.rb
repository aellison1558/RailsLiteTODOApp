require_relative('./controller_base')
require_relative('../models/todo_list.rb')
require_relative('../models/todo_item.rb')
require_relative('../models/detail.rb')
require 'byebug'

class DetailsController < ControllerBase

  def create
    @detail = Detail.new(params["detail"])
    if @detail.save
      flash[:notice] = "Saved Detail successfully"
      redirect_to ('/list/' + @detail.list.id.to_s)
    else
      flash.now[:errors] = "Something went wrong"
      render :new
    end
  end

  def new
    @detail = Detail.new
    @items = TodoItem.all
  end

end
