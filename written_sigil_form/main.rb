require '../require_dir/require_dir'
require_dir '../lib' #require the entire partitioned array library
DB_SIZE = 2
PARTITION_AMOUNT = 3
OFFSET = 1
DEFAULT_PATH = './sl_api_db'
DB_NAME = 'sl_api_db'
wsa = ManagedPartitionedArray.new(db_size: DB_SIZE, partition_amount_and_offset: PARTITION_AMOUNT + OFFSET, db_path: DEFAULT_PATH, db_name: DB_NAME) #written sigil array data


# Array of partitioned arrays?

class WrittenSigils
  def initialize(parititioned_array: wsa)
    @parititioned_array = parititioned_array
  end
 



end

# create a 26*2 array of sigils
# each number is a sigil
# 0th entry in the partitioned array signifies whether the sigil is a mirror or not

# each sigil is a 2D array of size 2x2
# if a sigil does not have 2 letters, the letter to the right remains undefined