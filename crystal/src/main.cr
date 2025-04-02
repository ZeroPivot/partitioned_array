require "./src/partitioned_array"
require "./src/managed_partitioned_array"
require "./src/file_context_managed_partitioned_array"
require "./src/file_context_managed_partitioned_array_manager"
require "./src/line_database"
require "./src/search_index"
require "./src/query_builder"
require "./src/migration"

# Demo usage of the LineDatabase
def run_db_demo
  puts "Creating LineDatabase..."
  db = LineDatabase.new
  
  puts "Creating users table..."
  db.create_table("users")
  
  puts "Setting active table to users..."
  db.set_active_table("users")
  
  puts "Inserting records..."
  id1 = db.insert({"name" => "John", "age" => 30, "email" => "john@example.com"})
  id2 = db.insert({"name" => "Jane", "age" => 25, "email" => "jane@example.com"})
  id3 = db.insert({"name" => "Bob", "age" => 40, "email" => "bob@example.com"})
  
  puts "Inserted records with IDs: #{id1}, #{id2}, #{id3}"
  
  puts "Fetching record with ID #{id1}..."
  record = db.get(id1.as(Int32))
  puts "Retrieved: #{record}"
  
  puts "Updating record..."
  db.update(id1.as(Int32), {"name" => "John Smith", "age" => 31})
  
  puts "Fetching updated record..."
  record = db.get(id1.as(Int32))
  puts "Updated record: #{record}"
  
  puts "Querying for users with age <= 30..."
  young_users = db.query({"age" => JSON::Any.new(30)})
  puts "Found #{young_users.size} users:"
  young_users.each { |user| puts "  #{user["name"]} (#{user["age"]})" }
  
  puts "Deleting record with ID #{id3}..."
  db.delete(id3.as(Int32))
  
  puts "Verifying deletion..."
  record = db.get(id3.as(Int32))
  puts "Record exists: #{!record.nil?}"
end

# Create and test a search index
def run_search_index_demo
  puts "\nCreating SearchIndex..."
  index = SearchIndex.new
  
  puts "Adding records to index..."
  # Add product data to index
  index.add_to_index("category", "electronics", 1)
  index.add_to_index("price", 599.99, 1)
  index.add_to_index("name", "Laptop", 1)
  
  index.add_to_index("category", "electronics", 2)
  index.add_to_index("price", 999.99, 2)
  index.add_to_index("name", "Smartphone", 2)
  
  index.add_to_index("category", "furniture", 3)
  index.add_to_index("price", 299.99, 3)
  index.add_to_index("name", "Desk", 3)
  
  puts "Searching for electronics..."
  electronics_ids = index.search("category", "electronics")
  puts "Found IDs: #{electronics_ids.to_a}"
  
  puts "Searching for price range 300-1000..."
  price_range_ids = index.search_range("price", 300, 1000)
  puts "Found IDs: #{price_range_ids.to_a}"
  
  puts "Searching for names starting with 'L'..."
  l_names_ids = index.search_prefix("name", "L")
  puts "Found IDs: #{l_names_ids.to_a}"
  
  puts "Saving index to files..."
  index.save_to_files!
end

# Test query builder
def run_query_builder_demo
  puts "\nCreating SearchIndex for QueryBuilder..."
  index = SearchIndex.new
  
  # Add employee data to index
  index.add_to_index("department", "engineering", 1)
  index.add_to_index("salary", 85000, 1)
  index.add_to_index("years", 3, 1)
  
  index.add_to_index("department", "engineering", 2)
  index.add_to_index("salary", 110000, 2)
  index.add_to_index("years", 8, 2)
  
  index.add_to_index("department", "marketing", 3)
  index.add_to_index("salary", 75000, 3)
  index.add_to_index("years", 5, 3)
  
  index.add_to_index("department", "marketing", 4)
  index.add_to_index("salary", 95000, 4)
  index.add_to_index("years", 6, 4)
  
  puts "Creating QueryBuilder..."
  qb = QueryBuilder.new(index)
  
  puts "Query: department = engineering AND salary > 100000"
  result = qb
    .where("department", QueryBuilder::Operator::EQ, "engineering")
    .where("salary", QueryBuilder::Operator::GT, 100000)
    .execute
    
  puts "Result IDs: #{result.to_a}"
  
  puts "Query: department = marketing AND years >= 5"
  result = qb = QueryBuilder.new(index)
  result = qb
    .where("department", QueryBuilder::Operator::EQ, "marketing")
    .where("years", QueryBuilder::Operator::GTE, 5)
    .execute
    
  puts "Result IDs: #{result.to_a}"
end

# Main function
def main
  puts "==== PartitionedArray Crystal Implementation Demo ===="
  
  puts "\n--- Basic LineDatabase Demo ---"
  run_db_demo
  
  puts "\n--- Search Index Demo ---"
  run_search_index_demo
  
  puts "\n--- Query Builder Demo ---"
  run_query_builder_demo
  
  puts "\n==== Demo Complete ===="
end

# Run the demo
main