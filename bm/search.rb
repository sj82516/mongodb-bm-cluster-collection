# frozen_string_literal: true
# This benchmark is for comparing the performance
# of the MongoDB clustered collection and normal collection
# https://www.mongodb.com/docs/upcoming/core/clustered-collections/

require_relative './framework'
require_relative '../utils/service'

$total = 1e7
$page_size = 1e5

# experiment _id for cluster collection
class IdSearch < BenchmarkFramework
  EXPERIMENT = 'Id search'

  CONTROL_NAME = 'normal search'
  CONTROL_COLLECTION = 'users'
  CONTROL_IS_CLUSTERED = false

  EXPERIMENT_NAME = 'cluster search'
  EXPERIMENT_COLLECTION = 'clustered_users'
  EXPERIMENT_IS_CLUSTERED = true

  OUTPUT_FILE_NAME = 'id_search_results.json'

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
    repo.batch_search(collection, data)
  end
end

IdSearch.new.run

# test secondary index performance
class EmailSearch < IdSearch
  EXPERIMENT = 'Secondary index search'

  CONTROL_NAME = 'normal email search'
  EXPERIMENT_NAME = 'cluster email search'

  OUTPUT_FILE_NAME = 'email_search_results.json'
  def pre_run
    @emails = []

    DataService.new.read_data_in_page($total, $page_size) do |data|
      documents = data.map { |r| { email: r[:email], _id: r[:bson_id] } }
      sample_size = $page_size / 5
      @emails += data.sample(sample_size).map { |r| r[:email] }
      @repo.batch_insert(@control_collection, documents)
      @repo.batch_insert(@experiment_collection, documents)
    end

    @repo.build_email_index(@control_collection)
    @repo.build_email_index(@experiment_collection)
  end

  def generate_data
    @emails.shuffle!
    queries = @emails.each_slice(1000).map {
      |emails| { email: { '$in': emails } }
    }
    yield [queries, queries]
  end
end

EmailSearch.new.run
