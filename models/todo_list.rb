require_relative('./active_record_base');

class TodoList < SQLObject
  self.finalize!

  self.has_many "items",
    class_name: "TodoItem",
    foreign_key: :list_id,
    primary_key: :id

  self.has_many_through "details", "items", "details"
end
