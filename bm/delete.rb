# frozen_string_literal: true
# This benchmark is for comparing the performance
# of the MongoDB clustered collection and normal collection
# https://www.mongodb.com/docs/upcoming/core/clustered-collections/

require_relative './framework'
require_relative '../utils/service'

$total = 1e6
$page_size = 1e4

class Delete < BenchmarkFramework
  EXPERIMENT = 'Id search'

  CONTROL_NAME = 'normal delete'
  CONTROL_COLLECTION = 'users'
  CONTROL_IS_CLUSTERED = false

  EXPERIMENT_NAME = 'cluster delete'
  EXPERIMENT_COLLECTION = 'clustered_users'
  EXPERIMENT_IS_CLUSTERED = true

  OUTPUT_FILE_NAME = 'delete_results.json'

  def pre_run
    @_ids = []

    DataService.new.read_data_in_page($total, $page_size) do |data|
      documents = data.map { |r| { email: r[:email], _id: r[:bson_id] } }
      sample_size = $page_size / 5
      @_ids += data.sample(sample_size).map { |r| r[:bson_id] }
      @repo.batch_insert(@control_collection, documents)
      @repo.batch_insert(@experiment_collection, documents)
    end
  end

  def generate_data
    @_ids.shuffle!
    queries = @_ids.each_slice(1000).map {
      |ids| { _id: { '$in': ids } }
    }
    yield [queries, queries]
  end

  def experiment_func(repo, collection, data)
    repo.batch_delete(collection, data)
  end
end

Delete.new.run
