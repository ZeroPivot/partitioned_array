require_relative "lib/managed_partitioned_array"
a= ManagedPartitionedArray.new
a.allocate
50.times do |i|
  a.add do |hash|
    hash[:name] = "name#{i}"
    hash[:age] = i
  end
end


p a[2,3, 2..3]