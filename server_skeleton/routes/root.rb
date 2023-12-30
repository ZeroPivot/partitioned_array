class MPMDBServer
  ROOT = ""
  hash_branch ROOT do |r|
    r.is do
      r.get do
        "root"
      end
    end
  end



end