require_relative "lib/managed_partitioned_array"
a= ManagedPartitionedArray.new
a.allocate
50.times do |i|
  a.add do |hash|
    hash[:name] = "name#{i}"
    hash[:age] = i
  end
end


p a[0,0..10, 20, 30, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49]