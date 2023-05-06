require 'thread'
require 'mongo'
require 'faker'

# just for convenience

CLUSTER_USERS = :cluster_users
USERS = :users

class MongoRepo
  def initialize
    @client = Mongo::Client.new(['localhost:27017'], database: 'test')
  end

  def prepare_collections
    prepare_clustered_collection
    prepare_normal_collection
  end

  def bm_insert(collection, data)
    exec_func = lambda do |slice_data|
      slice_data.each_slice(10000).to_a.each do |d|
        @client[collection].insert_many(d)
      end
    end

    run_in_parallel(data, exec_func)
  end

  def bm_secondary_index(collection)
    @client[collection].indexes.create_one(
      { email: 1 },
      name: 'email_index',
    )
  end

  def bm_find(collection, ids, emails)
    data = ids || emails
    exec_func = lambda do |data|
      data.each do |d|
        next @client[collection].find(_id: d).first unless ids.nil?
        @client[collection].find(email: d).first
      end
    end

    run_in_parallel(data, exec_func)
  end

  def bm_delete(collection, ids, emails)
    data = ids || emails
    exec_func = lambda do |slice_data|
      slice_data.each do |data|
        next @client[collection].delete_one(_id: data) unless data.nil?
        @client[collection].delete_one(email: data)
      end
    end

    run_in_parallel(data, exec_func)
  end

  private

  def prepare_clustered_collection
    @client[CLUSTER_USERS].drop
    @client[CLUSTER_USERS].create({
      :clustered_index => {
        :key => { :_id => 1 },
        :unique => true,
      }
    })
    # bm_secondary_index(CLUSTER_USERS)
  end

  def prepare_normal_collection
    @client[USERS].drop
    @client[USERS].create
    # bm_secondary_index(USERS)
  end

  def run_in_parallel(data, exec_func)
    return if data.empty?

    con_num = 4

    threads = []

    slice_data = data.each_slice(data.size / con_num)
    con_num.times do |i|
      threads << Thread.new do
        exec_func.call(slice_data.to_a[i])
      end
    end

    threads.each(&:join)
  end
end
