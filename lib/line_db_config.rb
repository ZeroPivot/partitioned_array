require_relative "line_reader"
require "json"

def generate_config()
  File.open("./db_config.json", "w") do |f|
    f.puts({"partition_amount" => 20, "endless_add" => true, "has_capacity" => true, "database_size" => 100,
   "dynamically_allocates" => true, "parent_folder" => "./database/CGMFS_db", "database_file_name" => "./db_list.txt"}.to_json)
  end
end

generate_config