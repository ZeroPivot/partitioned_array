
require_relative 'lib/file_context_managed_parttioned_array.rb'

test = FileContextManagedPartitionedArray.new
test.new_database(database_index_name_str: "test", db_path: "./DB", db_name: "test")
test.new_database(database_index_name_str: "test2", db_path: "./DB", db_name: "test2")
test.db("test").set(0) do |entry|
  entry["test"] = "test"
end
test.db("test").save_everything_to_files!

puts test.db("test").get(0, hash: true)

test.db("test2").set(1) do |entry|
  entry["test2"] = "test2"
end

test.db("test2").save_everything_to_files!

puts test.db("test2").get(1, hash: true)
puts test.db("test2").get(1, hash: true)

# create 200 new databases

test = FileContextManagedPartitionedArray.new()
test.new_database("test2")
test.start_database!("test2")
test.start_database!("test3")
a=test.db("test2").set(0) do |entry|
  entry["added data"] = "hello dragonruby"
  entry["test2"] = "test2"
end
a=test.db("test2").set(1) do |entry|
  entry["added data"] = "hello dragonruby"
  entry["test2"] = "test2"
end
test.db("test2").save_everything_to_files!


a=test.db("test3").set(1) do |entry|
  entry["added data"] = "hello dragonruby"
  entry["test2"] = "test2"
end
test.db("test3").save_everything_to_files!
test.db("test2").save_everything_to_files!
test.delete_database!("test")
test.delete_database_from_index!("test2")
p y.get(0, hash: true)
