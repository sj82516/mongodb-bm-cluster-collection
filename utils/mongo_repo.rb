require 'thread'
require 'mongo'
require 'faker'

# wrap mongodb operation
class MongoRepo
  def initialize
    @client = Mongo::Client.new(['localhost:27017'], database: 'test')
  end

  def prepare_collection(collection_name, is_clustered = false)
    @client[collection_name].drop
    options = is_clustered ? {
      :clustered_index => {
        :key => { :_id => 1 },
        :unique => true,
      }
    } : {}

    @client[collection_name].create(options)
  end

  def batch_insert(collection, data)
    exec_func = lambda do |slice_data|
      slice_data.each_slice(10000).to_a.each do |d|
        @client[collection].insert_many(d)
      end
    end

    run_in_parallel(data, exec_func)
  end

  def build_email_index(collection)
    @client[collection].indexes.create_one(
      { email: 1 },
      name: 'email_index',
    )
  end

  def batch_search(collection, data)
    exec_func = lambda do |slice_data|
      slice_data.each do |d|
        @client[collection].find(d)
      end
    end

    run_in_parallel(data, exec_func)
  end

  def batch_delete(collection, query)
    exec_func = lambda do |slice_data|
      slice_data.each do |data|
        @client[collection].delete_many(data)
      end
    end

    run_in_parallel(query, exec_func)
  end

  private

  def prepare_normal_collection
    @client[USERS].drop
    @client[USERS].create
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
