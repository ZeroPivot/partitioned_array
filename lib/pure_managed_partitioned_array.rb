class PureManagedPartitionedArray < ManagedPartitionedArray
  def initialize(db_size: DB_SIZE, partition_amount_and_offset: PARTITION_AMOUNT + OFFSET, db_path: DEFAULT_PATH, db_name: DB_NAME) 
    super(db_size: db_size, partition_amount_and_offset: partition_amount_and_offset, db_path: db_path, db_name: db_name)
  end
end