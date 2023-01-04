# The Partitioned Array, Managed Partitioned Array and File Context Managed Partitioned Array/Manager: Fundamental Data Structures and Array-Of-Hashes Database System

## Updates:
* January 3, 2023 (1/3/2023) - 1:00PM - Added FileContextManagedPartitionedArrayManager info on implementation at the end of README.md; this is the final product for the partitioned array, and turns it into a database
* TODO: Add documentation on the FileContextManagedPartitionedArrayManager class, and the FileContextManagedPartitionedArray class, like a quick tutorial


**Quick Compatibility List:**
* **Ruby 3.0+**: (`/lib/partitioned_array`) - *lib/managed_partitioned_array.rb* - **Fully Compatible**

* **jruby**: (`same as ruby 3.0 version`)  - *lib/managed_partitioned_array.rb* - **Fully Compatible**

* **DragonRuby**: (`/lib/dr_partitioned_array`) - *dr_managed_partitioned_array.rb* - **Fully Compatible**

* **Python**: *./managed_partitioned_array_python* folder - **(WIP)**

* **NOTE**: File Context Managed Partitioned Array/Manager (lib/file_context_managed_partitioned_array.rb / lib/file_context_managed_partitioned_array_manager.rb ["FCMPA/FCMPAM"]) are in the same `lib` folder; documentation at the bottom

## Initial Notes


(There is much less need for the basis partitioned_array.rb, as managed_partitioned_array.rb does everything, and more.)

Note: Managed partitioned array info is near the bottom of this README.md file, and will be updated accordingly; just need to get a bearing on how im going to write this documentation (Last updated: 10/19/2022 12:11PM)

See: CHANGELOG.md for a list of changes
## Update 11/18/2022

* Added FileContextManagedPartitionedArray info on implementation at the end of README.md
* Information on HTTP/HTTPS implementation of a `FCMPA` in `HTTPS_FCMPA_README.md`

## Update 9/25/2021

In case one's wondering, the additional layer of abstraction is called a ManagedPartitionedArray, which keeps a track of the array index and inherits from PartitionedArray. When I go to work today 2-4 hours from now I'm going to work on the ManagedPartitionedArray Documentation. -ArityWolf

## WIP NOTES (Last Updated: 9/14/2022)
In recent developments, this only describes the low-level ish nature of a PartitionedArray data structure, and even that is still incomplete.

In the lib folder, I have completed the (inherited from PartitonedArray) ManagedPartitionedArray class which describes how to treat a PartitionedArray closer to an array with bounds set to it, and that is what the main focus of the rest of this documentation will be about. In the end, everything about the data structure will be described in full detail.

You can think of a partitioned array in general as an array that has disk I/O and saves the data in .json, but it could be extended to deal with whatever you throw at it

It will also be fully compatible with the DragonRuby game development toolkit albeit with a few minor caveats, and several details that need to be addressed in some way

# Later Goals
* Documentation on all code on this page, leaving nothing out
* Prettify the code, and make as efficient as possible
* Lower level language implementation(s)
* DragonRuby file I/O implementation, aimed at both Linux/Windows

----------------------------------------------------------------
# Everything below this line needs to be updated

(But it does document the PartitionedArray class alright thus far)
* Upcoming additions: ManagedPartitonedArray documentation, and cleaned up PartitionedArray documentation

## Synopsis

A partitioned array is defined as a datastructure which has "partitioned elements" within what should be a `regular array`

The data structure used for every element in the array is a Ruby Hash, or otherwise known as an Associative Array

Example of how a `partitioned array` is structured:

`figure 69 (partitioned array structure):`
`[[0, 1, 2], [3, 4], ..., [n, ..., n+1]]`

`Caveat`: The first partition (`[0,1,2]` always contains the 0th element otherwise known as `0` )

However, as a note: The partitioned array algorithm is currently coded in a way that it does not actually use subarrays; the algorithm takes responsibility for all aspects of the data structure (partitions, ranges, etc), so an array when defined by `fig 69`, would look slightly different, it would look like...

`[0, 1, 2, 3, 4, n, n+1, n+2, ..., n+k]`

Note: The basic idea is you can store the array itself onto disk and "switch off" certain partitions, thus allowing for Ruby's Garbage collector to take hold

```ruby
require_relative 'partitioned_array'

pa = PartitionedArray.new
pa.allocate

pa.add do |hash|
    hash['value'] = "value"
end

pa.get(id) # => "Get an element of the partitioned array, using binary search"

pa.delete_partition_subelement(id, partition_id)
pa.delete(id)
pa.set_partition_subelement(id, partition_id, &block)
pa.delete_partition(partition_id)
pa.get_partition(partition_id)
pa.set(id, &block)
pa.add_partition

pa.add_partition #=> "dynamically allocates new partition sub-elements to the partitioned array, as defined by the constants"

pa.load_from_files! #=> loads database from json files, using Ruby's JSON parser
pa.load_partition_from_file!(partiion_id) #=> loads a given partition id from the @data_arr array
pa.save_partition_to_file!
pa.save_all_to_files!

pa.dump_to_json!

=begin
The above is basic usage for the partitioned array data structure. For tested code and configuration options, see below.
=end
```
**WIP.** - ***Last updated: 4.27.2022***

A partitioned array data structure which works with JSON for disk storage, and a pure JSON parser is in progress. With two constants, the algorithm creates a data structure and allocates empty associative array elements and understands the structure of the partitions.

The main purpose was I needed a way to divide an array into subelements, so that in gamedev I can flip on and off portions of the array in question to save on memory.

The data structure overall is an `Array-Of-Hashes`.

## Usage

### Assumed Constants
```ruby
# DB_SIZE > PARTITION_AMOUNT
PARTITION_AMOUNT = 5 # Number of subelements per partition. CAVEAT: the first partition quantity is always PARTITION_AMOUNT + 1
DB_SIZE = 3 # The DB_SIZE is the total # of partitions within the array; starts at 0
OFFSET = 1 # This came with the math
PURE_RUBY = false # WIP
DB_NAME = 'partitioned_array_slice'
DEFAULT_PATH = './CGMFS'
DEBUGGING = false
```
### Examples 

`main_refined.rb, visuals.rb`

Visualization of the partitions within `@data_arr`

`visuals.rb`
```ruby
# Visuals; Show the basic data structure, by filling with entries, where each id is a part of that respective array partition
def allocate_ranges_sequentially(partitioned_array)
  range_arr = partitioned_array.range_arr
  range_arr.each_with_index do |range, range_index|
    range.to_a.each_with_index do |range_element, range_element_index|
      partitioned_array.set_partition_subelement(range_element_index, range_index) do |partition_subelement|
        partition_subelement["id"] = range_index
      end
    end
  end
  partitioned_array.data_arr
end
```

`main_refined.rb`
```ruby
require_relative 'partitioned_array'
require_relative 'visuals'

# Create a new data structure and allocate the partition to memory
partitioned_array = PartitionedArray.new
partitioned_array.allocate

#Returns the partition elements within the first partition within @data_arr; returns a hash of relevant data if argument is true (optional)
# Examples
id = 0
p "First Partition in @data_arr: #{partitioned_array.get_partition(id, hash: false)}" # get a partition (a chunk) of a partition element withinn @data_arr
p "First Element in @data_arr: #{partitoned_array.get(id)}" # gets an entry from @data_arr directly
puts

# Set an element within @data_arr; ignores partitions and goes for raw ids

partitioned_array.set(id) do |hash|
   hash["first"] = "1st"   
end

partitioned_array.set(id + 1) do |hash|
    hash["second"] = "2nd"
end

# add a partition to the @range_arr; @data_arr, add partition_amount_andoffset to @rel_arr, @db_size increases by one
partitioned_array.add_partition 
partitioned_array.add_partition

allocate_ranges_sequentially(partitioned_array)

partitioned_array.add_partition

last_element = -1
partitioned_array.set(last_element) do |hash|
    hash["last"] = "Nth"
end

# All that has to be done to store the PartitionedArray instance data
=begin
PartitionedArray#load_from_json!()
PartitionedArray#dump_to_json!
PartitionedArray#save_partition_to_file!
PartitionedArray#load_partition_from_file!
=end

# Test to see if file loading and unloading creates equivalent data structures
puts "Before:"

p partitioned_array.data_arr
p partitioned_array.partition_amount_and_offset
p partitioned_array.range_arr
p partitioned_array.rel_arr

_data_arr = partitoned_array.data_arr
_partition_amount_and_offset = partitioned_array.partition_amount_and_offset
_range_arr = partitioned_array.range_arr
_rel_arr = y.rel_arr

partitioned_array.dump_to_json!
partitioned_array.load_from_json!

# assert tests
p "@data_arr remains the same: #{partitioned_array.data_arr == _data_arr}"
p "@partition_amount_and_offset: #{partitioned_array.partition_amount_and_offset == _partition_amount_and_offset}"
p "@range_arr: #{partitioned_array.range_arr == _range_arr}"
p "@rel_arr: #{partitioned_array.rel_arr == _rel_arr}"

p "Get a certain slice of @data_arr (0..4): #{partitiond_array.data_arr[0..4]}"
p "Load partition data into @data_arr (0th): #{partitioned_array.load_partition_from_file!(0)}"

partitioned_array.save_partition_to_file!(0)

# PartitionedArray#set_partition_subelement(id, partition_id, &block)
success = partitioned_array.set_partition_subelement(0, 0) do |hash|
    hash[:modified] = "0, 0"
end
p "successfully modified partition subelement: #{success}"
p "New @data_arr: #{@data_arr}"

```
Output
```ruby
"First Partition in @data_arr: [{}, {}, {}, {}, {}, {}, {}]"
"First Element in @data_arr: {}"

Before:
[{"first"=>"1st", "id"=>0}, {"second"=>"2nd", "id"=>0}, {"id"=>0}, {"id"=>0}, {"id"=>0}, {"id"=>0}, {"id"=>0}, {"id"=>1}, {"id"=>1}, {"id"=>1}, {"id"=>1}, {"id"=>1}, {"id"=>1}, {"id"=>2}, {"id"=>2}, {"id"=>2}, {"id"=>2}, {"id"=>2}, {"id"=>2}, {"id"=>3}, {"id"=>3}, {"id"=>3}, {"id"=>3}, {"id"=>3}, {"id"=>3}, {"id"=>4}, {"id"=>4}, {"id"=>4}, {"id"=>4}, {"id"=>4}, {"id"=>4}, {}, {}, {}, {}, {}, {"last"=>"Nth"}]
6
[0..6, 7..12, 13..18, 19..24, 25..30, 31..36]
[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 18, 19, 20, 21, 22, 23, 24, 24, 25, 26, 27, 28, 29, 30, 30, 31, 32, 33, 34, 35, 36]
"@data_arr remains the same: true"
"@partition_amount_and_offset: true"
"@range_arr: true"
"@rel_arr: true"
"Get a certain slice of @data_arr (0..4): [{"first"=>"1st", "id"=>0}, {"second"=>"2nd", "id"=>0}, {"id"=>0}, {"id"=>0}, {"id"=>0}]"
"Load partition data into @data_arr (0th): [{"first"=>"1st", "id"=>0}, {"second"=>"2nd", "id"=>0}, {"id"=>0}, {"id"=>0}, {"id"=>0}, {"id"=>0}, {"id"=>0}]"
"successfully modified partition subelement: true"
"New @data_arr: [{"first"=>"1st", "id"=>0, :modified=>"0, 0"}, {"second"=>"2nd", "id"=>0}, {"id"=>0}, {"id"=>0}, {"id"=>0}, {"id"=>0}, {"id"=>0}, {"id"=>1}, {"id"=>1}, {"id"=>1}, {"id"=>1}, {"id"=>1}, {"id"=>1}, {"id"=>2}, {"id"=>2}, {"id"=>2}, {"id"=>2}, {"id"=>2}, {"id"=>2}, {"id"=>3}, {"id"=>3}, {"id"=>3}, {"id"=>3}, {"id"=>3}, {"id"=>3}, {"id"=>4}, {"id"=>4}, {"id"=>4}, {"id"=>4}, {"id"=>4}, {"id"=>4}, {}, {}, {}, {}, {}, {"last"=>"Nth"}]"
```
# Managed Partitioned Array Data Structure
## Synopsis
# PartitionedArray/ManagedPartitionArray

This will talk about the Partitioned Array and its suggested counterpart superset, the`ManagedPartitionedArray (lib/managed_partitioned_array.rb)`

## ManagedPartitionedArray

(Last updated: 10/19/2022 12:11PM)

###  Instance Methods 
```ruby
mpa = mpa.archive_and_new_db!

mpa.load_archive_no_auto_allocate!

mpa = mpa.load_from_archive!(partition_archive_id: @max_partition_archive_id)

mpa.at_capacity? # Depends on the MPA variables

mpa.add(return_added_element_id: true, &block)

mpa.get(id, hash: false) #see PartitionedArray

mpa.load_everything_from_files! # in PA class, its load_all_from_files!

mpa.save_everything_to_files!

mpa.increment_max_partition_archive_id!
```
### Finite Length arrays
```ruby

mpa = ManagedPartitionedArray(max_capacity: "data_arr_size" || Integer, dynamically_allocates: false)
```

Capable of jumping to a new file partition
### Never ending array adds
```ruby

mpa = ManagedPartitionedArray.new(endless_add: true, has_capacity: false, dynamically_allocates: true)`
```

### Dynamic Allocation
```ruby

mpa = ManagedPartitionedArray.new(dynamically_allocates: true)
```

### Array split by file partitions
```ruby
 mpa = ManagedPartitionedArray.new(max_capacity: "data_arr_size",   db_size: DB_SIZE,   partition_amount_and_offset: PARTITION_AMOUNT + OFFSET,   db_path: "./db/sl",   db_name: 'sl_slice')
```
Where `max_capacity` could be the max `@data_arr` size, or a defined integer

Check if `mpa.at_capacity?` to figure out if the MPA is at capacity

#### Switching and allocating to a new file partition

```ruby
mpa = ManagedPartitionedArray.new(max_capacity: "data_arr_size",   db_size: DB_SIZE,   partition_amount_and_offset: PARTITION_AMOUNT + OFFSET,   db_path: "./db/sl",   db_name: 'sl_slice')
mpa = mpa.archive_and_new_db!
mpa.save_everything_to_files!
```

It implements the Value Object pattern; the other archive is closed and saved and the partitioned array starts out in a new partition that mirrors the others if max_capacity = "data_arr_size"

"data_arr_size" is sure to fill the entire array before throwing  at_capacity? is true.

# File Context Managed Partitioned Array (Definition)

We have: `file_context_array["file_db_name_string"].managed_partitioned_array[mpa_db_file_id_integer].partitioned_array(db_id, id)`

let `PA (partitioned array) = P`

let `MPA = a = Q < P`

let `FCA = f = b<a ~= b.a`

`f` expands to `f.(Q < P)` => `f.(b < a)` =~> `f.(b.a)`

and, 


we have in this context:


`file_context_array["file_db_name_string"].managed_partitioned_array[mpa_db_file_id_integer].partitioned_array(db_id, id)`

Could also be written as: `file_context_array["file_db_name_string"].(managed_partitioned_array[mpa_db_file_id_integer] < partitioned_array(db_id, id))`

Methods:

* VERSION v1.0.2a - Prettified, and listed all functions below


```ruby
FCMPA#load_indexer_db! - loads the indexing DB

FCMPA#new_database! - creates a new database

FCMPA#start_database! - starts a database

FCMPA#delete_database_from_index! - deletes a database from the index

FCMPA#add_database_to_index! - adds a database to the index

FCMPA#db(database_index_name = @active_database) - returns the database

FCMPA#set_active_database(database_index_name) - sets the active database

FCMPA#stop_database!(database_index_name) - stops a database

FCMPA#stop_databases! - stops all databases

FCMPA#save_databases! - saves all databases

FCMPA#load_database!(database_index_name = @active_database) - loads a database

FCMPA#load_databases! - loads all databases

FCMPA#delete_database!(database_index_name = @active_database) - deletes a database

FCMPA#get_databases_list - returns a list of databases

FCMPA#set_new_file_archive!(database_index_name = @active_database) - sets a new file archive for a database

FCMPA#each(database_index_name, hash: @traverse_hash) - traverses a database

FCMPA#each_not_nil(database_index_name, hash: @traverse_hash) - traverses a database, skipping nil values
```


# File Context Managed Partitioned Array *Manager* (Definition)
The database manager is the `FCMPAM` class. It is a singleton class that manages the `FCMPA` class. The `FCMPA` class manages the `MPA` class. The `MPA` class manages the `PA` class.

FCMPAM.FCMPA.MPA.PA or FCMPAM.FCMPA.(MPA < PA)

## Defined Methods (FCMPAM = File Context Managed Partitioned Array Manager = file_context_managed_partitioned_array_manager.rb)


```ruby
FCMPAM#database(database_name = @active_database): returns the database object

FCMPAM#database_table(database_name: @active_database, database_table: @active_table): returns the database table object

FCMPAM#new_database!(database_name): creates a new database

FCMPAM#new_table!(database_name:, database_table:): creates a new table in the database

FCMPAM#active_database(database_name): sets the active database

FCMPAM#active_table(database_table): sets the active table

FCMPAM#table(database_table = @active_table): returns the active table

FCMPAM#database(database_name = @active_database): returns the active database
```

# Generate Documentation

`gem install yard`

## In Directory:

`yard doc`