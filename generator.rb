

class GenData
  def initialize
    @id_map = {}
  end

  def gen_ids(n)
    n.times.map do
      id = BSON::ObjectId.new
      while @id_map[id.to_s]
        id = BSON::ObjectId.new
      end
      @id_map[id.to_s] = true
      id
    end
  end
end
