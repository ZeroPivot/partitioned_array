# VERSION 1.0.1-release - First release 

DB_LIST = "db_list.txt"

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


def check_file_duplicates(check, filename=DB_LIST)
  lines = read_file_lines(filename)
  array_duplicates?(check, lines)
end


def array_duplicates?(check, array_of_strings)
  puts array_of_strings.include?(check)
  array_of_strings.include?(check)
end


def write_lines(lines_array, filename=DB_LIST)
  lines_array.each do |line|
    File.open(filename, "a") do |f|
      f.puts line
    end
  end
end


def remove_line(name, filename=DB_LIST)
  lines = read_file_lines(filename)
  lines = lines.delete(name)
  write_lines(lines, filename)
end

def test1()
  write_lines(["database_1", "database_2", "database_3", "database_4"])
end

def test()
  a = read_file_lines
  puts a
  puts array_duplicates?("test", a)
  write_line("test") if !array_duplicates?("test", a)
end

#test1
#test