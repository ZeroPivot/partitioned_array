require_relative "lib/file_context_managed_partitioned_array_manager"

a = FileContextManagedPartitionedArrayManager.new
#a.new_database!("test_database33")
a.new_table!(database_name: "test_database33", database_table: "test_database_table24")

a.database_table(database_name: "test_database33", database_table: "test_database_table24").set(0) do |hash|
  hash["test2"] = "test"
  hash["test3"] = "test"
end

puts a.database_table(database_name: "test_database33", database_table: "test_database_table24").get(0)
# 5) save the table to files
a.database_table(database_name: "test_database33", database_table: "test_database_table24").save_everything_to_files!

a.database("test_database33").save_everything_to_files!

a.active_table("test_database_table24")
a.active_database("test_database33")


a.table_next_file_context!

a.database_table.set(0) do |hash|
  hash["test2"] = "test file context 1"
  hash["test3"] = "test file context 1"
end

a.database_table.get(0, hash: true)

a.database_table.save_everything_to_files!

a.new_database!("test_database69")
a.new_database!("test_database33")
a.database("test_database69").save_everything_to_files!
puts "Test Database Index List; we created 'test_database33' and 'test_database69'"
puts "without additional descriptors:"
#p a.table("_DATABASE_LIST_INDEX").get(0);
puts 
puts "with additional descriptors:"
#p a.table("_DATABASE_LIST_INDEX").get(0, hash: true); 
#a.man_index.delete_database!("test_database33")
puts "Test Database Index List; we deleted 'test_database33'"
puts "without additional descriptors:"
#a.man_index.delete_database!("test_database69")
p a.man_index.db("test_database33")
#a.delete_database_index_entry!("test_database33")
#a.delete_database_index_entry!("test_database69")
#p a.table 
