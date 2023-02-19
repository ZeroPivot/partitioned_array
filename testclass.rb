class Test 
  def initialize(a: 1, b: 2, c: 3, d:4, e:5, f:6, g:7, h:8, i:9, j:10, k:11, l:12, m:13, n:14, o:15, p:16, q:17, r:18, s:19, t:20, u:21, v:22, w:23, x:24, y:25, z:26)
    @a = a
    @b = b
    @c = c
    @d = d
    @e = e
    @f = f
    @g = g
    @h = h
    @i = i
    @j = j
    @k = k
    @l = l
    @m = m
    @n = n
    @o = o
    @p = p
    @q = q
    @r = r
    @s = s
    @t = t
    @u = u
    @v = v
    @w = w
    @x = x
    @y = y
    @z = z
    p @z
  end
end
class Test2 < Test
  def initialize(z: 99999)
    super
  end
end

Test2.new(z: 9999999999)



# Path: testclass.rb
# Compare this snippet from db_init.rb:
# require 'json'
# LATEST_PA_VERSION = "v1.2.3"
# require_relative "lib/managed_partitioned_array"
# PARTITION_AMOUNT = 9 # The initial, + 
