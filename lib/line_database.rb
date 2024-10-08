# rubocop:disable Style/FrozenStringLiteralComment, Style/StringLiterals, Style/RequireOrder, Style/NegatedIf
require_relative "partitioned_array_database"
require_relative "line_reader"

# VERSION 1.0.0-release - First release
PARENT_FOLDER = "./PAD_db" # rubocop:disable Style/MutableConstant
def load_pad(parent_folder: PARENT_FOLDER)
  db_linelist = read_file_lines("db_list.txt")
  # puts db_linelist
  db_list = {}
  db_linelist.each do |db_name|
    db_list[db_name] = PAD.new(database_folder_name: db_name) if !parent_folder
    db_list[db_name] = PAD.new(database_folder_name: "#{parent_folder}/#{db_name}") if parent_folder
  end
  db_list
end
# rubocop:enable Style/FrozenStringLiteralComment, Style/StringLiterals, Style/RequireOrder, Style/NegatedIf
