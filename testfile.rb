require 'sqlite3'
db = SQLite3::Database.new 'barbershop.db'
db.results_as_hash = true

db.execute 'select * from Users' do |row|
  print row['username']
  print "\t-\t"
  puts row['datestemp']
  #puts "#{row[1]} записался на #{row[3]}"
  puts "============"
end

