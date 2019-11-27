require 'sqlite3'
db = SQLite3::Database.new 'test.s'
db.execute "INSERT INTO cars (Name, Price) VALUES ('Jagyar', '7777')"
db.close