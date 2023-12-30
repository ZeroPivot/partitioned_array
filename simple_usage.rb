# Ignore LineDB for a second; the managed partitioned array is all you technically need to create a singular array database

require_relative "lib/line_db" # you can still require using LineDB and get all the functionality of LineDB, technically, since they all get required under LineDB


MPA = ManagedPartitionedArray # alias for ManagedPartitionedArray

a = MPA.new(label_integer: false, label_ranges: false, partition_addition_amount: 5, dynamically_allocates: true, db_size: 10, partition_amount_and_offset: 5, db_path: "linedb_guide", db_name: "db_tutorial")



#a.allocate
a.load_everything_from_files!


a.add do |partition| # index 0 in @data_arr
  partition[1] = "hello"
  partition[2] = "world"
  partition[3] = "!"
end

a.save_everything_to_files!

p a.get(0) # => "hello"
p a.data_arr[0] # => "hello"

p a.get(1) # => "world"
p a.data_arr[1] # => "world"

p a.get(2) # => "!"
p a.data_arr[2] # => "!"


# Path: lib/line_db.rb

a.archive_and_new_db! # goto the next file context (good for archiving and moving straight to a new file context)
# file context: a particular file folder in the LineDB database library that acts as its own set of files for a particular database

p a.get(0).to_s # => nil
p a.data_arr[0].to_s # => nil

p a.get(1).to_s # => nil
p a.data_arr[1].to_s # => nil

p a.get(2).to_s # => nil
p a.data_arr[2].to_s # => nil

# everything is nil, because this is a file context that we have not added to yet

a.save_everything_to_files!

p a[0] # use MPA notation to get a range of values -> this 
p a[1]
p "#{a[0][1]} DragonRiders" # => "hello DragonRiders"
p a.get_partition(0) # use MPA notation to get a range of values
