# Managers
module LineDatabaseFactory
  def self.line_db
    line_db = LineDB.new
  end
end

class FileMethodsManager
  include FileMethods
end