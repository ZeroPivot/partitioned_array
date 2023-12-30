class PartitionedArray:
    # Access individual instance variables with caution...
    range_arr = None
    rel_arr = None
    db_size = None
    data_arr = None
    partition_amount_and_offset = None
    db_path = None
    db_name = None
    partition_addition_amount = None

    # DB_SIZE > PARTITION_AMOUNT
    PARTITION_AMOUNT = 3  # The initial, + 1
    OFFSET = 1  # This came with the math, but you can just state the PARTITION_AMOUNT in total and not worry about the offset in the end
    DB_SIZE = 10  # Caveat: The DB_SIZE is the total # of partitions, but you subtract it by one since the first partition is 0, in code.
    DEFAULT_PATH = './CGMFS'  # default fallSback/write to current path
    DEBUGGING = False
    PAUSE_DEBUG = False
    DB_NAME = 'partitioned_array_slice'
    PARTITION_ADDITION_AMOUNT = 1  # The amount of partitions to add when the array is full
    DYNAMICALLY_ALLOCATES = True  # If true, the array will dynamically allocate more partitions when it is full

    def __init__(self, partition_addition_amount=PARTITION_ADDITION_AMOUNT, dynamically_allocates=DYNAMICALLY_ALLOCATES, db_size=DB_SIZE, partition_amount_and_offset=PARTITION_AMOUNT + OFFSET, db_path=DEFAULT_PATH, db_name=DB_NAME):
        # Here is the explanation for the code below:
        # 1. Partition addition amount: the amount of partitions that will be added once the database reaches its limit. For example, if the partition addition amount is 10, then the database will add 10 new partitions to the database once it reaches its limit.
        # 2. Dynamically allocates: if the database is not full, then the database will not dynamically allocate new partitions. This is to prevent the database from creating too many partitions.
        # 3. DB size: the size of the database. If the database reaches its limit, then the database will start to dynamically allocate new partitions.
        # 4. Partition amount and offset: the amount of partitions and offset. For example, if the offset is 10 and the partition amount is 3, then the database will have 3 partitions, which are 10, 20, and 30.
        # 5. DB path: the path of the database.
        # 6. DB name: the name of the database.
        # 7. Data array: the array that contains the data.
        # 8. Range array: the array that contains the partitions.
        # 9. Rel array: the array that contains the partition locations.
        # 10. DB name: the name of the database.

        self.db_size = db_size
        self.partition_amount_and_offset = partition_amount_and_offset
        self.allocated = False
        self.db_path = db_path
        self.data_arr = []  # the data array which contains the data, has to be partitioned accordingly
        self.range_arr = []  # the range array which maintains the partition locations
        self.rel_arr = []  # a basic array from 1..n used in binary search
        self.db_name = db_name

        self.partition_addition_amount = partition_addition_amount
        self.dynamically_allocates = dynamically_allocates
        


    def range_db_get(range_arr, db_num):
        range_arr[db_num]


  #  def debug(string):
   #     p(string) if DEBUGGING


    def delete(id):
        deleted = False
        if id <= (@data_arr.size - 1):
            @data_arr[id] = nil
            deleted = True
        return deleted


    def load_dynamically_allocates_from_file():
        with open(@db_path + '/' + 'dynamically_allocates.json', 'r') as file:
            @dynamically_allocates = json.load(file)


    def save_dynamically_allocates_to_file():
        #puts "in PA: @dynamically_allocates = #{@dynamically_allocates}" 
        touch(@db_path + '/' + 'dynamically_allocates.json')
        with open(@db_path + '/' + 'dynamically_allocates.json', 'w') as file:
            file.write(json.dumps(@dynamically_allocates))


    def delete_partition_subelement(id, partition_id):
        # delete the partition's array element to what is specified
        @data_arr[@range_arr[partition_id].to_a[id]] = nil