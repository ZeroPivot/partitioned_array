require_relative "lib/line_db"
a= ManagedPartitionedArray.new
a.allocate
50.times do |i|
  a.add do |hash|
    hash[:name] = "name#{i}"
    hash[:age] = i
  end
end


p a[0]

b = LineDB.new
p b["aritywolf", "kejento"]

p b["vel"]