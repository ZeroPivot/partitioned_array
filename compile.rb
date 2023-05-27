# Create a simple Ruby script
File.write('test.rb', 'puts "Hello, world!"')

# Compile the Ruby script into bytecode
bytecode = RubyVM::InstructionSequence.compile_file('test.rb')

# Get a binary string representation of the bytecode
binary_string = bytecode.to_binary

# Write the binary string to a file
File.binwrite('test.bin', binary_string)

# Read the binary data from the file
binary_string = File.binread('test.bin')

# Load the binary data into an InstructionSequence object
bytecode = RubyVM::InstructionSequence.load_from_binary(binary_string)

# Evaluate the bytecode
bytecode.eval