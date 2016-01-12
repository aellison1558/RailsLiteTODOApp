require_relative('./active_record_base');

class Detail < SQLObject
  self.finalize!

  self.belongs_to "item",
    class_name: "TodoItem",
    foreign_key: :item_id,
    primary_key: :id

  self.has_one_through "list", "item", "list"

end
