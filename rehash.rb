require_relative "lib/line_db"


test = LineDB.new
test["test"].pad.new_table!(database_name: "test", database_table: "test")

test["test"].pad["test", "test"].add do |hash|
    hash["test"] = "test"
    end

                    test["test"].pad["test", "test"].rehasher!
                    test["test"].pad["test", "test"].save_everything_to_files!
