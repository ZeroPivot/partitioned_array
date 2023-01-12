require_relative "lib/file_context_managed_partitioned_array_manager"

a = FileContextManagedPartitionedArrayManager.new
puts "1) Initialize a new database named \"test_database33\""
a.new_database!("test_database33")
puts "2) initialize a new table and associate it with test_database33"
a.new_table!(database_name: "test_database33", database_table: "test_database_table24")
puts "3) set values to the first index of the table"
a.database_table(database_name: "test_database33", database_table: "test_database_table24").set(0) do |hash|
  hash["test2"] = "test"
  hash["test3"] = "test"
end
puts "4) get the values from the first index of the table"
puts "Value of test_database33's test_database_table24's first index:"
puts a.database_table(database_name: "test_database33", database_table: "test_database_table24").get(0)
# 5) save the table to files
a.database_table(database_name: "test_database33", database_table: "test_database_table24").save_everything_to_files!
puts "6) save the database to files"
a.database("test_database33").save_everything_to_files!
puts "7) active_table and active_database: avoid redundant typing"
a.active_table("test_database_table24")
a.active_database("test_database33")

puts "8) set the next file context"
a.table_next_file_context!
puts "9) set values to the first index of the table"
a.database_table.set(0) do |hash|
  hash["test2"] = "test file context 1"
  hash["test3"] = "test file context 1"
end
puts "10) get the values from the first index of the table, returning additional information (hash: true)"
a.database_table.get(0, hash: true)
puts "11) save the table to files"
a.database_table.save_everything_to_files!

puts "new test\n\n\n\n\n\n\n"
a.new_database!("test_database69")
p a.table("_DATABASE_LIST_INDEX").get(0, hash: true)
#p a.table 
