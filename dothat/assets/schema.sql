DROP TABLE IF EXISTS todo_category;
DROP TABLE IF EXISTS todo_item;
DROP TABLE IF EXISTS todo_reminders;

-- Having the categories for todo
CREATE TABLE todo_category (
    cid INTEGER PRIMARY KEY, -- id of the category
    name STRING UNIQUE NOT NULL -- name of the category
);

-- Storing the items corresponding to categories
CREATE TABLE todo_item (
    iid INTEGER PRIMARY KEY,
    for_category INTEGER NOT NULL, -- specifies what category this item is for
    name STRING NOT NULL, -- name of the item
    due_date INTEGER, -- due date stored as seconds since epoch
    importance INTEGER NOT NULL DEFAULT 1 CHECK (importance > 0 AND importance < 6), -- importance of task
    item_status INTEGER NOT NULL DEFAULT 0 CHECK (item_status >= 0 AND item_status < 4), -- 0=not_started, 1=inprogress, 2=finished, 3=overdue
    FOREIGN KEY (for_category) REFERENCES todo_category(cid) ON DELETE CASCADE, -- key constraint
    CONSTRAINT unique_name_id UNIQUE (name, for_category)
);

-- Storing the reminders for the given item
CREATE TABLE todo_reminders (
    for_item INTEGER NOT NULL, -- reminder for which item
    reminder_time INTEGER NOT NULL, -- the reminder time stored as seconds since epoch
    FOREIGN KEY (for_item) REFERENCES todo_item(iid) ON DELETE CASCADE,
    CONSTRAINT unique_reminder UNIQUE (for_item, reminder_time)
);
