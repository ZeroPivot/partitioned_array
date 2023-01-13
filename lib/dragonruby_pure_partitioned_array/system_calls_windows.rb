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
  File.open "#{pwd}\\#{path}\\#{file}", "r" do |f|
    #$gtk.read_file("#{pwd}\\#{path}\\#{file}")
  f.read
end

  end

#untested
def rmdir(folder_path)
  $gtk.system("cmd /c rmdir /s /q \"#{folder_path}\"")
end

def writefile_bindir(file_path_name, contents)
  #$gtk.write_file("#{pwd}\\#{file_path_name}", contents)
  File.open("#{pwd}\\#{file_path_name}", "w") do |f|
    f.write(contents)
  end
end



def mkdir_bindir(path)
  if !File.exist?("#{pwd}\\#{path}")
    $gtk.system("cmd /c mkdir \"#{path}\"")
  end
  
end

def slash
 "\\"
end

def log(say)
  File.open("#{pwd}\\log.txt", "a") do |f|
    f.write(say)
  end

end

