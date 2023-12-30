class JSONeval
  def self.range_arr2ruby(json_string)
    eval(json_string)
  end

  def self.data_arr2ruby(json_string)
    eval(json_string)
  end

  def self.rel_arr2ruby(json_string);end

  def self.ruby2json(ruby_ds)

    u_string = ruby_ds.to_s
    u_string = u_string.gsub "=>", ":" # replace ruby's hashrocket with JSON's :
    u_string = u_string.gsub "nil", "\"null\"" # replace Ruby's nil with null
    u_string = u_string.gsub "\"null\"", "null"
    u_string
  end

  def self.json2ruby(json_string)
    u_string = "\"#{json_string}\""
    u_string = u_string.gsub ":", "=>" # replace ruby's hashrocket with JSON's :
    #u_string.gsub! '\"', '"'
    u_string= u_string.gsub "null", "nil" # replace json's null with nil\
    u_string= u_string.gsub "\"nil\"", "nil" # replace json's null with nil\
    eval(u_string)
  end
end