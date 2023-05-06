# frozen_string_literal: true
# This benchmark is for comparing the performance
# of the MongoDB clustered collection and normal collection
# https://www.mongodb.com/docs/upcoming/core/clustered-collections/

require_relative './framework'
require_relative '../utils/service'

class Insert < BenchmarkFramework
  EXPERIMENT = 'insert'
  CONTROL_NAME = 'normal inserts'
  CONTROL_COLLECTION = 'users'
  CONTROL_IS_CLUSTERED = false

  EXPERIMENT_NAME = 'cluster inserts'
  EXPERIMENT_COLLECTION = 'clustered_users'
  EXPERIMENT_IS_CLUSTERED = true

  OUTPUT_FILE_NAME = 'insert_results.json'

  def generate_data
    total = 4e7
    page_size = 1e6
    DataService.new.read_data_in_page(total, page_size) do |data|
      documents = data.map { |r| { email: r[:email] } }
      yield [documents, documents]
    end
  end

  def experiment_func(repo, collection, data)
    repo.batch_insert(collection, data)
  end
end

Insert.new.run
