
class ManagedPartitionedArrayDR < ManagedPartitionedArray

  

  def increment_max_partition_archive_id!
    @max_partition_archive_id = @max_partition_archive_id.to_i
    @max_partition_archive_id += 1
    puts "max_partition_archive_id: #{@max_partition_archive_id}"
    File.open(@db_path + '/' + "max_partition_archive_id.json", "w") do |f|
      f.write(JSONeval.ruby2json(@max_partition_archive_id))
      
    end
  end

  def save_db_name_with_no_archive_to_file!
    File.open(File.join("#{@db_path}", "db_name_with_no_archive.json"), "w") do |f|
      f.write(JSONeval.ruby2json(@original_db_name))
    end
  end

  def load_db_name_with_no_archive_from_file!
    File.open(File.join("#{@db_path}", "db_name_with_no_archive.json"), "r") do |f|
      @original_db_name = JSONeval.json2ruby(f.read)
    end
  end

  def save_has_capacity_to_file!
    File.open(File.join("#{@db_path}/#{@db_name}", "has_capacity.json"), "w") do |f|
      f.write(JSONeval.json2ruby(@has_capacity))
    end
  end

  def save_endless_add_to_file!
    File.open(File.join("#{@db_path}/#{@db_name}", "endless_add.json"), "w") do |f|
      f.write(JSONeval.json2ruby(@endless_add))
    end
  end

  def save_last_entry_to_file!
    if @partition_archive_id == 0      
      File.open(File.join("#{@db_path}/#{db_name_with_archive(db_name: @original_db_name)}", 'last_entry.json'), 'w') do |file|
        file.write(JSONeval.ruby2json(@latest_id))
      end
    else      
      File.open(File.join("#{@db_path}/#{db_name_with_archive(db_name: @original_db_name)}", 'last_entry.json'), 'w') do |file|
        file.write(JSONeval.ruby2json(@latest_id))
      end
    end
  end

  def load_endless_add_from_file!
    File.open(File.join("#{@db_path}/#{@db_name}", "endless_add.json"), "r") do |f|
      @endless_add = JSONeval.json2ruby(f.read)
    end
  end

  def load_has_capacity_from_file!
    File.open(File.join("#{@db_path}/#{@db_name}", "has_capacity.json"), "r") do |f|
      @has_capacity = JSONeval.json2ruby(f.read)
    end
  end

  def save_last_entry_to_file!
    if @partition_archive_id == 0      
      File.open(File.join("#{@db_path}/#{db_name_with_archive(db_name: @original_db_name)}", 'last_entry.json'), 'w') do |file|
        file.write(JSONeval.json2ruby(@latest_id))
      end
    else      
      File.open(File.join("#{@db_path}/#{db_name_with_archive(db_name: @original_db_name)}", 'last_entry.json'), 'w') do |file|
        file.write(JSONeval.json2ruby(@latest_id))
      end
    end
  end

  def load_last_entry_from_file!
    File.open(File.join("#{@db_path}/#{db_name_with_archive(db_name: @original_db_name)}", 'last_entry.json'), 'r') do |file|
      @latest_id = JSONeval.json2ruby(file.read)
    end
  end

  def save_partition_archive_id_to_file!
    File.open(File.join("#{@db_path}/#{db_name_with_archive(db_name: @original_db_name)}", 'partition_archive_id.json'), 'w') do |file|
      file.write(JSONeval.json2ruby(@partition_archive_id))
    end
  end

  def load_partition_archive_id_from_file!
    File.open(File.join("#{@db_path}/#{db_name_with_archive(db_name: @original_db_name)}", 'partition_archive_id.json'), 'r') do |file|
      @partition_archive_id = JSONeval.json2ruby(file.read)
    end
  end

  def save_max_partition_archive_id_to_file!
    File.open(File.join(@db_path, 'max_partition_archive_id.json'), 'w') do |file|
      file.write(JSONeval.json2ruby(@max_partition_archive_id))
    end  
  end

def initialize_max_partition_archive_id!
  # if the max_partition_archive_id.json file does not exist, create it and set it to 0
  if !File.exist?(File.join("#{@db_path}", "max_partition_archive_id.json"))
    mkdir_bindir(@db_path)
    File.open(File.join("#{@db_path}", "max_partition_archive_id.json"), "w") do |f|
      f.write(0)
    end
    @max_partition_archive_id = 0
  else
  # if the max_partition_archive_id.json file does exist, load it
  File.open(File.join("#{@db_path}", "max_partition_archive_id.json"), "r") do |f|
    @max_partition_archive_id = JSONeval.json2ruby(f.read)
  end
  end
end

def save_partition_to_file!(partition_id, db_folder: @db_folder)
  partition_data = get_partition(partition_id)
  path = "#{@db_path}/#{@db_name}"
  mkdir_bindir(path)
  File.open("#{path}/#{db_folder}/#{@db_name}_part_#{partition_id}.json", 'w') { |f| f.write(JSONeval.ruby2json(partition_data)) }
end


  def load_max_partition_archive_id_from_file!
    # puts "1 @db_path: #{@db_path}"
    if File.exist?(File.join(@db_path, 'max_partition_archive_id.json'))
      File.open(File.join(@db_path, 'max_partition_archive_id.json'), 'r') do |file|
        @max_partition_archive_id = JSONeval.json2ruby(file.read)
      end
    else
      FileUtils.touch(File.join(@db_path, 'max_partition_archive_id.json'))
      File.open(File.join(@db_path, db_name_with_archive(db_name: @db_name, partition_archive_id: @partition_archive_id)), 'w') do |file|
        file.write(0.to_s)
      end      
      return 0
    end
  end

  def save_max_capacity_to_file!
    File.open(File.join(@db_path, 'max_capacity.json'), 'w') do |file|
      file.write("\"#{@max_capacity}\"")
    end
  end

  def load_max_capacity_from_file!
    File.open(File.join(@db_path, 'max_capacity.json'), 'r') do |file|
      @max_capacity = JSONeval.json2ruby(file.read)
    end
  end

  

  def save_partition_addition_amount_to_file!
    mkdir_bindir("#{@db_path}/#{@db_name}")
    File.open(File.join("#{@db_path}/#{@db_name}", 'partition_addition_amount.json'), 'w') do |file|
      file.write(JSONeval.ruby2json(@partition_addition_amount))
    end
  end

  def load_partition_addition_amount_from_file!
    File.open(File.join("#{@db_path}/#{@db_name}", 'partition_addition_amount.json'), 'r') do |file|
      @partition_addition_amount = JSONeval.json2ruby(file.read)
    end
  end




  

end