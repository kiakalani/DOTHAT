DROP TABLE IF EXISTS todo_category;
DROP TABLE IF EXISTS todo_item;
DROP TABLE IF EXISTS todo_reminders;

-- Having the categories for todo
CREATE TABLE todo_category (
    name STRING UNIQUE NOT NULL
);

-- Storing the items corresponding to categories
CREATE TABLE todo_item (
    for_category INTEGER NOT NULL, -- specifies what category this item is for
    name STRING UNIQUE NOT NULL, -- name of the item
    description STRING DEFAULT '', -- description for the item stored as a text
    due_date INTEGER NOT NULL, -- due date stored as seconds since epoch
    importance INTEGER NOT NULL CHECK (importance > 0 AND importance < 6), -- importance of task
    FOREIGN KEY (for_category) REFERENCES todo_category(ROWID) ON DELETE CASCADE -- key constraint
);

-- Storing the reminders for the given item
CREATE TABLE todo_reminders (
    for_item INTEGER NOT NULL, -- reminder for which item
    reminder_time INTEGER NOT NULL, -- the reminder time stored as seconds since epoch
    FOREIGN KEY (for_item) REFERENCES todo_item(ROWID) ON DELETE CASCADE
);
