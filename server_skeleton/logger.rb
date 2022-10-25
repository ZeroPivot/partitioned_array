def log(text)
  File.open("log.txt", "a") do |f|
    f.puts "LOG: #{text}"
  end
end