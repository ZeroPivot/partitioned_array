require 'fileutils'

# Define the directory to glob
directory = './'

# Get all Ruby files in the directory
ruby_files = Dir.glob("#{directory}/**/*.rb")

# Create a directory for RBS files if it doesn't exist
rbs_directory = './'
FileUtils.mkdir_p(rbs_directory)

# Iterate over each Ruby file and generate RBS files
ruby_files.each do |file|
  rbs_file = File.join(rbs_directory, "#{File.basename(file, '.rb')}.rbs")
  system("rbs prototype rb #{file} > #{rbs_file}")
end

puts "RBS files generated in #{rbs_directory}"
