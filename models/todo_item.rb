require_relative('./active_record_base');

class TodoItem < SQLObject
  self.finalize!

  self.belongs_to 'list',
    class_name: "TodoList",
    foreign_key: :list_id,
    primary_key: :id

    self.has_many "details",
      class_name: "Detail",
      foreign_key: :item_id,
      primary_key: :id
end
