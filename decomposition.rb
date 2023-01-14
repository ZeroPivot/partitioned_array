require_relative "lib/line_db"
ldb = LineDB.new
p ldb.class # => LineDB
zero = ldb["aritywolf"] # PartitionedArrayDatabase
p zero.class # => PartitionedArrayDatabase
b = ldb.db("aritywolf").pad
p b.class # => FileContextPartitionedArrayManager
p b.man_db.class # => FileContextManagedPartitionedArray
c = b.man_db
p c.fcmpa_active_databases["_DATABASE_LIST_INDEX"].class # => ManagedPartitionedArray

LineDatabase = LineDB
PAD = PartitionedArrayDatabase
FCMPAM = FileContextManagedPartitionedArrayManager
MPA = ManagedPartitionedArray
PA = PartitionedArray

### Inheritance Tree###########
# X < Y means X inherits from Y
###############################
# LineDatabase.PAD.FCMPAM.FCMPA.(MPA < PA)
#                 =
# LineDB.PAD.FCMPAM.FCMPA.MPA
