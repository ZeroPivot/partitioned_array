def mkdir(path)  
  $gtk.system("mkdir \"#{path}\"")
end

def pwd
  #`cmd /c cd`.strip
  `pwd`.strip
end

def writefile(path, contents)
  $gtk.write_file(path, contents)
end

def readfile_bindir(path, file)
  File.open "#{pwd}/#{path}/#{file}", "r" do |f|
    f.read
  end
end

def writefile_bindir(full_file_path_name, contents)
  readlink = "#{pwd}/#{full_file_path_name}"
  File.open(readlink, "w") do |f|
    f.write(contents)
  end

end


def mkdir_bindir(path)
  $gtk.system("mkdir \"#{path}\"")
end

def slash 
  "/"
end

def log(say)
  File.open("#{pwd}/log.txt", "a") do |f|
    f.write(say)
  end
end
