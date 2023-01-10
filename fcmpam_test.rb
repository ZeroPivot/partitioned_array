require_relative "lib/file_context_managed_partitioned_array_manager"

a = FileContextManagedPartitionedArrayManager.new
a.new_database!("test_database33")
a.new_table!(database_name: "test_database33", database_table: "test_database_table24")
a.database_table(database_name: "test_database33", database_table: "test_database_table24").set(0) do |hash|
  hash["test2"] = "test"
  hash["test3"] = "test"
end

puts a.database_table(database_name: "test_database33", database_table: "test_database_table24").get(0)

a.database_table(database_name: "test_database33", database_table: "test_database_table24").save_everything_to_files!
a.database("test_database33").save_everything_to_files!
a.active_table("test_database_table24")
a.active_database("test_database33")
p a.table
p a.database
a.table_next_file_context!
p a.table 