require_relative "lib/managed_partitioned_array"
a = ManagedPartitionedArray.new
a.allocate
a.add do |i|
  i["test"] = "test"
end

y = a.replicate
p y


# Path: testclass.rb
# Compare this snippet from db_init.rb:
# require 'json'
# LATEST_PA_VERSION = "v1.2.3"
# require_relative "lib/managed_partitioned_array"
# PARTITION_AMOUNT = 9 # The initial, + 
