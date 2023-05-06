# frozen_string_literal: true
# This benchmark is for comparing the performance
# of the MongoDB clustered collection and normal collection
# https://www.mongodb.com/docs/upcoming/core/clustered-collections/

require 'benchmark'
include Benchmark

require_relative './framework'
require_relative '../utils/service'


# experiment uuid for cluster collection
class UUIDInsert < BenchmarkFramework
  EXPERIMENT = 'UUID in cluster collection'

  CONTROL_NAME = 'normal _id inserts'
  CONTROL_COLLECTION = 'id_users'
  CONTROL_IS_CLUSTERED = true

  EXPERIMENT_NAME = 'cluster uuid inserts'
  EXPERIMENT_COLLECTION = 'uuid_users'
  EXPERIMENT_IS_CLUSTERED = true

  OUTPUT_FILE_NAME = 'uuid_insert_results.json'

  def generate_data
    total = 2e7
    page_size = 1e6
    DataService.new.read_data_in_page(total, page_size) do |data|
      documents = data.map { |r| { email: r[:email] } }
      uuid_documents = data.map { |r| { email: r[:email], _id: r[:uuid] } }
      yield [documents, uuid_documents]
    end
  end

  def experiment_func(repo, collection, data)
    repo.batch_insert(collection, data)
  end
end

UUIDInsert.new.run
