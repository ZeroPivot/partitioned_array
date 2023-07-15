def mkdir(path)
  $gtk.system("cmd /c mkdir \"#{path}\"")
end

def pwd
  `cmd /c cd`.strip
end

def writefile(path, contents)
  $gtk.write_file(path, contents)
end

def readfile_bindir(path, file)
  $gtk.read_file("#{pwd}\\#{file}")
end

def writefile_bindir(file_path_name, contents)
  $gtk.write_file("#{file_path_name}", contents)
end

def mkdir_bindir(path)
  $gtk.system("cmd /c mkdir \"#{path}\"")
end
