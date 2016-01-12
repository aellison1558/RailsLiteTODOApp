CREATE TABLE todo_lists (
  id INTEGER PRIMARY KEY,
  title VARCHAR(255) NOT NULL
);

CREATE TABLE todo_items (
  id INTEGER PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  list_id INTEGER NOT NULL,
  done VARCHAR(255),

  FOREIGN KEY(list_id) REFERENCES todo_list(id)
);

CREATE TABLE details (
  id INTEGER PRIMARY KEY,
  body VARCHAR(255) NOT NULL,
  item_id INTEGER NOT NULL,

  FOREIGN KEY(item_id) REFERENCES todo_item(id)
);

INSERT INTO
  todo_lists (id, title)
VALUES
  (1, "House Cleaning"), (2, "Errands");

INSERT INTO
  todo_items (id, title, list_id, done)
VALUES
  (1, "Clean Bathroom", 1, 'true'), (2, "Clean Kitchen", 1, 'false'), (3, "Buy Groceries", 2, 'false'), (4, "Pick Up Dry Cleaning", 2, 'false');

INSERT INTO
  details (id, body, item_id)
VALUES
  (1, "Mop Floor", 1), (2, "Scrub Sink", 1), (3, "Sweep Floor", 2), (4, "Wash Dishes", 2), (5, "Buy Meat", 3), (6, "Buy Vegetables", 3);
