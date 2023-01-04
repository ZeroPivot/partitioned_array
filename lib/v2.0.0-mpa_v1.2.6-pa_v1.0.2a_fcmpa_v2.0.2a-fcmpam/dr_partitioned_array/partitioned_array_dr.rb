#require 'app/lib/partitioned_array/managed_partitioned_array.rb'
require 'app/lib/dr_partitioned_array/partitioned_array.rb'



class PartitionedArrayDR < PartitionedArray
  # loads the files within the directory CGMFS/partitioned_array_slice
  # needed things
  # range_arr => it is the array of ranges that the database is divided into
  # data_arr => it is output to json
  # rel_arr => it is output to json
  # part_} => it is taken from the range_arr subdivisions; perform a map and load it into the database, one by one
  
  def load_dynamically_allocates_from_file!
    File.open(@db_path + '/' + 'dynamically_allocates.json', 'r') do |file|
      @dynamically_allocates = JSONeval.json2ruby(file.read)
    end
  end

    
  def string2range(range_string)
    split_range = range_string.to_s.split("..")
    split_range[0].to_i..split_range[1].to_i
  end


  def save_dynamically_allocates_to_file!
    #puts "in PA: @dynamically_allocates = #{@dynamically_allocates}"
     mkdir_bindir(@db_path)
    #FileUtils.touch(@db_path + '/' + 'dynamically_allocates.json')
    File.open(@db_path + '/' + 'dynamically_allocates.json', 'w') do |file|
      file.write(JSONeval.ruby2json(@dynamically_allocates))
    end
  end
  
  def load_from_files!(db_folder: @db_folder)
    load_partition_addition_amount_from_file!
    load_dynamically_allocates_from_file!
    # @db_size needs to be taken into account and changed accordingly
    path = "#{@db_path}/#{@db_name}"    
    @partition_amount_and_offset = File.open("#{path}/partition_amount_and_offset.json", 'r') { |f| JSONeval.json2ruby(f.read) }
    @range_arr = File.open("#{path}/range_arr.json", 'r') { |f| JSONeval.range_arr2ruby(f.read) }
    @range_arr.map!{ |range_element| string2range(range_element) }
    @rel_arr = File.open("#{path}/rel_arr.json", 'r') { |f| JSONeval.json2ruby(f.read) }
    @db_size = File.open("#{path}/db_size.json", 'r') { |f| JSONeval.json2ruby(f.read) }
    data_arr_set_partitions = []
    0.upto(@db_size - 1) do |partition_element_index|
      data_arr_set_partitions << File.open("#{path}/#{@db_name}_part_#{partition_element_index}.json", 'r') { |f| JSONeval.json2ruby(f.read) }
      @data_arr = data_arr_set_partitions.flatten # side effect: if you don't flatten it, you get an array with partitioned array elements
    end
    @allocated = true
  end

# Plan: be able to dump @data_arr to disk anytime you want
  def load_partition_from_file!(partition_id)
    path = "#{@db_path}/#{@db_name}"
    # @data_arr = File.open("#{path}/data_arr.json", 'r') { |f| JSONeval.json2ruby(f.read) } # can write the entire array to disk for certain operations
    @partition_amount_and_offset = File.open("#{path}/partition_amount_and_offset.json", 'r') { |f| JSONeval.json2ruby(f.read) }
    @range_arr = File.open("#{path}/range_arr.json", 'r') { |f| JSONeval.range_arr2ruby(f.read) }
    @range_arr.map!{|range_element| string2range(range_element) }
    @rel_arr = File.open("#{path}/rel_arr.json", 'r') { |f| JSONeval.json2ruby(f.read) }
    sliced_range_arr = @range_arr[partition_id].to_a.map { |range_element| range_element }
    partition_data = File.open("#{path}/#{@db_name}_part_#{partition_id}.json", 'r') { |f| JSONeval.json2ruby(f.read) }
    ((sliced_range_arr[0].to_i)..(sliced_range_arr[-1].to_i)).to_a.each do |range_element|
      @data_arr[range_element] = partition_data[range_element]
    end
    @data_arr[@range_arr[partition_id]]
  end

  def save_partition_to_file!(partition_id, db_folder: @db_folder)
    partition_data = get_partition(partition_id)
    path = "#{@db_path}/#{@db_name}"
    File.open("#{path}/#{db_folder}/#{@db_name}_part_#{partition_id}.json", 'w') { |f| f.write(JSONeval.ruby2json(partition_data)) }
  end

  def save_partition_addition_amount_to_file!(db_folder: @db_folder)
    path = "#{@db_path}/#{@db_name}"
    mkdir_bindir("#{path}/#{db_folder}")
    #FileUtils.touch("#{path}/#{db_folder}/partition_addition_amount.json")
    File.open("#{path}/#{db_folder}/partition_addition_amount.json", 'w') { |f| f.write(JSONeval.ruby2json(@partition_amount_and_offset)) }
  end

  def load_partition_addition_amount_from_file!(db_folder: @db_folder)
    path = "#{@db_path}/#{@db_name}"
    @partition_addition_amount = File.open("#{path}/#{db_folder}/partition_addition_amount.json", 'r') { |f| JSONeval.json2ruby(f.read) }
  end


  def mkdir_bindir(path)
    $gtk.system("cmd /c mkdir \"#{pwd}\\#{path}\"")
  end

  def save_all_to_files!(db_folder: @db_folder, db_path: @db_path, db_name: @db_name)
    # Bug: files are not being written correctly.
    # Fix: (8/11/2022 - 5:55am) - add db_size.json
    
    unless File.exist?(db_path)
      mkdir_bindir(db_path)
    end
    path = "#{db_path}/#{db_name}"

    unless File.exist?(path)
      mkdir_bindir(path)
    end

    save_partition_addition_amount_to_file!
    save_dynamically_allocates_to_file!

    File.open("#{path}/#{db_folder}/partition_amount_and_offset.json", 'w'){|f| f.write(JSONeval.ruby2json(@partition_amount_and_offset)) }
    File.open("#{path}/#{db_folder}/range_arr.json", 'w'){|f| f.write(JSONeval.ruby2json(@range_arr)) }
    File.open("#{path}/#{db_folder}/rel_arr.json", 'w'){|f| f.write(JSONeval.ruby2json(@rel_arr)) }
    File.open("#{path}/#{db_folder}/db_size.json", 'w'){|f| f.write(JSONeval.ruby2json(@db_size)) }
    debug path
    0.upto(@db_size-1) do |index|
      # FileUtils.touch("#{path}/#{db_folder}/#{@db_name}_part_#{index}.json")
      `cmd /c copy nul >> "#{path}/#{db_folder}/#{@db_name}_part_#{index}.json"` # for windows
      File.open("#{path}/#{@db_name}_part_#{index}.json", 'w') do |f|
        partition = get_partition(index)
        debug_and_pause("partition index: #{index}")
        debug "partition index: #{index}"
        debug "@db_size: #{@db_size}"
        debug "partition: #{partition}"
        debug "@rel_arr: #{@rel_arr}"
        debug "@range_arr: #{@range_arr}"
        debug "@data_arr: #{@data_arr.size}"
        debug "@data_arr: #{@data_arr}"
        f.write(JSONeval.ruby2json(partition))
      end
    end
  end
  

end

