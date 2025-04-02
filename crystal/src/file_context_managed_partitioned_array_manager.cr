require "./file_context_managed_partitioned_array"
require "json"
require "file_utils"

class FileContextManagedPartitionedArrayManager
  property fcmpa : FileContextManagedPartitionedArray
  property databases : Hash(String, Hash(String, ManagedPartitionedArray))
  property active_database : String?
  property active_table : String?
  
  def initialize
    @fcmpa = FileContextManagedPartitionedArray.new
    @databases = {} of String => Hash(String, ManagedPartitionedArray)
    @active_database = nil
    @active_table = nil
    
    load_all_databases!
  end
  
  def load_all_databases!
    # Get all databases from the indexer
    indexer = @fcmpa.fcmpa_db_indexer_db
    db_index = indexer.get(@fcmpa.fcmpa_db_index_location)
    
    return if db_index.nil?
    
    db_index.as_h.each do |db_name, db_info|
      next if db_name == "metadata"
      
      # Start the database
      @fcmpa.start_database!(db_name)
      @databases[db_name] = {} of String => ManagedPartitionedArray
      
      # Load all tables
      if db_info.as_h["db_table_name"]? && db_info.as_h["db_table_name"].as_a.size > 0
        db_info.as_h["db_table_name"].as_a.each do |table_name|
          load_table!(db_name, table_name.as_s)
        end
      end
    end
  end
  
  def load_table!(db_name : String, table_name : String)
    return false if !@databases[db_name]?
    
    db = @fcmpa.start_database!(db_name)
    
    # Find the table entry
    table_id = nil
    
    db.data_arr.each_with_index do |partition, partition_index|
      next if partition.nil?
      
      partition.each do |position_key, value|
        if value.as_h[table_name]?
          table_id = partition_index * db.partition_amount_and_offset + position_key.to_i
          break
        end
      end
      
      break if table_id
    end
    
    if table_id
      # Create and load the table
      table_path = "#{@fcmpa.db_path}_#{db_name}/tables"
      
      table = ManagedPartitionedArray.new(
        endless_add: true,
        dynamically_allocates: true,
        has_capacity: false,
        db_name: "table_#{table_name}",
        db_path: table_path,
        label_integer: true,
        label_ranges: false
      )
      
      begin
        table.load_everything_from_files!
      rescue
        table.allocate
        table.save_everything_to_files!
      end
      
      @databases[db_name][table_name] = table
      true
    else
      false
    end
  end
  
  def create_database(db_name : String) : Bool
    # Check if database already exists
    indexer = @fcmpa.fcmpa_db_indexer_db
    db_index = indexer.get(@fcmpa.fcmpa_db_index_location)
    
    if db_index && db_index[db_name]?
      return false
    end
    
    # Create database
    result = @fcmpa.new_database(db_name)
    
    if result
      @databases[db_name] = {} of String => ManagedPartitionedArray
    end
    
    result
  end
  
  def create_table(db_name : String, table_name : String) : Bool
    # Make sure database exists
    if !@databases[db_name]?
      create_database(db_name)
    end
    
    # Get database
    db = @fcmpa.start_database!(db_name)
    
    # Check if table already exists
    db.data_arr.each do |partition|
      next if partition.nil?
      
      partition.each_value do |value|
        return false if value.as_h[table_name]?
      end
    end
    
    # Create table entry
    id = db.add(true)
    
    if id
      # Add table data
      db.set(id.as(Int32)) do |entry|
        entry[table_name] = {
          "name" => table_name,
          "created_at" => Time.now.to_s
        }
      end
      
      # Update database metadata
      db_index = @fcmpa.fcmpa_db_indexer_db.get(@fcmpa.fcmpa_db_index_location)
      
      if db_index && db_index[db_name]?
        tables = db_index[db_name]["db_table_name"].as_a
        tables << JSON::Any.new(table_name)
        
        @fcmpa.fcmpa_db_indexer_db.set(@fcmpa.fcmpa_db_index_location) do |entry|
          entry[db_name]["db_table_name"] = JSON::Any.new(tables)
        end
        
        @fcmpa.fcmpa_db_indexer_db.save_everything_to_files!
      end
      
      # Create table database
      table_path = "#{@fcmpa.db_path}_#{db_name}/tables"
      FileUtils.mkdir_p(table_path)
      
      table = ManagedPartitionedArray.new(
        endless_add: true,
        dynamically_allocates: true,
        has_capacity: false,
        db_name: "table_#{table_name}",
        db_path: table_path,
        label_integer: true,
        label_ranges: false
      )
      
      table.allocate
      table.save_everything_to_files!
      
      @databases[db_name][table_name] = table
      db.save_everything_to_files!
      
      true
    else
      false
    end
  end
  
  def set_active_database(db_name : String) : Bool
    if @databases[db_name]?
      @active_database = db_name
      @active_table = nil
      true
    else
      false
    end
  end
  
  def set_active_table(table_name : String) : Bool
    return false if @active_database.nil?
    
    if @databases[@active_database][table_name]?
      @active_table = table_name
      true
    else
      false
    end
  end
  
  def insert(data : Hash)
    return nil if @active_database.nil? || @active_table.nil?
    
    table = @databases[@active_database][@active_table]
    id = table.add(true)
    
    if id
      table.set(id) do |entry|
        data.each do |key, value|
          entry[key] = value
        end
      end
      table.save_everything_to_files!
      id
    else
      nil
    end
  end
  
  def get(id : Int32)
    return nil if @active_database.nil? || @active_table.nil?
    
    table = @databases[@active_database][@active_table]
    table.get(id)
  end
  
  def update(id : Int32, data : Hash)
    return false if @active_database.nil? || @active_table.nil?
    
    table = @databases[@active_database][@active_table]
    record = table.get(id)
    
    if record
      table.set(id) do |entry|
        data.each do |key, value|
          entry[key] = value
        end
      end
      table.save_everything_to_files!
      true
    else
      false
    end
  end
  
  def delete(id : Int32)
    return false if @active_database.nil? || @active_table.nil?
    
    table = @databases[@active_database][@active_table]
    record = table.get(id)
    
    if record
      table.set(id) { |entry| entry.clear }
      table.save_everything_to_files!
      true
    else
      false
    end
  end
  
  def query(conditions : Hash)
    return [] of Hash(String, JSON::Any) if @active_database.nil? || @active_table.nil?
    
    table = @databases[@active_database][@active_table]
    results = [] of Hash(String, JSON::Any)
    
    table.data_arr.each_with_index do |partition, partition_index|
      next if partition.nil?
      
      partition.each do |position_key, record|
        next if record.as_h.empty?
        
        matches_all = true
        
        conditions.each do |key, value|
          if !record.as_h[key]? || record.as_h[key] != value
            matches_all = false
            break
          end
        end
        
        if matches_all
          id = partition_index * table.partition_amount_and_offset + position_key.to_i
          record_with_id = record.as_h.clone
          record_with_id["id"] = JSON::Any.new(id)
          results << record_with_id
        end
      end
    end
    
    results
  end
  
  def list_databases : Array(String)
    @databases.keys
  end
  
  def list_tables(db_name : String) : Array(String)
    return [] of String unless @databases[db_name]?
    
    @databases[db_name].keys
  end
  
  def backup(backup_path : String)
    timestamp = Time.now.to_s("%Y%m%d%H%M%S")
    backup_dir = File.join(backup_path, "backup_#{timestamp}")
    
    FileUtils.mkdir_p(backup_dir)
    
    # Backup indexer database
    indexer_backup_path = File.join(backup_dir, "indexer")
    FileUtils.mkdir_p(indexer_backup_path)
    
    FileUtils.cp_r(File.join(@fcmpa.fcmpa_db_folder_name, @fcmpa.fcmpa_db_indexer_name), indexer_backup_path)
    
    # Backup all databases
    @databases.each do |db_name, tables|
      db_backup_path = File.join(backup_dir, db_name)
      FileUtils.mkdir_p(db_backup_path)
      
      # Backup database files
      db_source_path = "#{@fcmpa.db_path}_#{db_name}"
      FileUtils.cp_r(db_source_path, db_backup_path)
    end
    
    backup_dir
  end
  
  def restore(backup_path : String)
    # Clear current databases
    @databases.clear
    
    # Restore indexer database
    indexer_backup_path = File.join(backup_path, "indexer", @fcmpa.fcmpa_db_indexer_name)
    FileUtils.cp_r(indexer_backup_path, @fcmpa.fcmpa_db_folder_name)
    
    # Reload indexer
    @fcmpa.load_indexer_db!
    
    # Get database names from the backup
    Dir.entries(backup_path).each do |entry|
      next if entry == "." || entry == ".." || entry == "indexer"
      
      db_backup_path = File.join(backup_path, entry)
      if File.directory?(db_backup_path)
        db_name = entry
        
        # Restore database files
        db_dest_path = "#{@fcmpa.db_path}_#{db_name}"
        FileUtils.rm_rf(db_dest_path)
        FileUtils.cp_r(db_backup_path, db_dest_path)
      end
    end
    
    # Reload all databases
    load_all_databases!
    
    true
  end
end