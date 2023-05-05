
require 'securerandom'


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

  def gen_uuids(n)
    n.times.map do
      id = SecureRandom.uuid
      while @id_map[id.to_s]
        id = SecureRandom.uuid
      end
      @id_map[id.to_s] = true
      id
    end
  end
end
