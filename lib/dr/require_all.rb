# re-implement lost code to make DragonRuby capable of requiring on OPERATING_SYSTEM calls, the operating system that DR is about to compile for.
# optional code includes system_calls_unix.rb and system_calls_windows.rb  

OPERATING_SYSTEM = "?"

#psuedorequires

# if OPERATING_SYSTEM == "windows"
# then require "lib/system_calls_windows.rb"
# elsif OPERATING_SYSTEM == "unix (linux || mac)"
# then require "lib/system_calls_unix.rb"
# else
#  puts "Operating system not recognized"
# end
