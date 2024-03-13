module FileMethods
  DB_LIST = "./db/db_list.txt"
  def read_lines(array)
    array.map { |line| line.chomp }
  end

  def read_multi_string(string)
    string.split("\n").map { |line| line.chomp }
  end

  def read_file_lines(file_name=DB_LIST)
    read_lines(File.readlines(file_name))
  end

  def write_line(line, filename=DB_LIST)
    File.open(filename, "a") do |f|
      f.puts line
    end
  end

  def remove_line(line, filename=DB_LIST)
    lines = read_file_lines
    lines.delete(line)
    File.open(filename, "w") do |f|
      lines.each do |line|
        f.puts line
      end
    end
  end

  def check_file_duplicates(check, filename=DB_LIST)
    lines = read_file_lines(filename)
    array_duplicates?(check, lines)
  end


  def array_duplicates?(check, array_of_strings)
    #puts array_of_strings.include?(check)
    array_of_strings.include?(check)
  end


  def write_lines(lines_array, filename=DB_LIST)
    lines_array.each do |line|
      File.open(filename, "a") do |f|
        f.puts line
      end
    end
  end
end  
