# frozen_string_literal: true
# This benchmark is for comparing the performance
# of the MongoDB clustered collection and normal collection
# https://www.mongodb.com/docs/upcoming/core/clustered-collections/

require 'benchmark'
include Benchmark

require_relative './mongo_repo'
require_relative './data/service'

total = 5e6
page_size = 1e6
REPORT_FILE = 'report.txt'

DataService.new.read_data_in_page(total, page_size) do |data|
  repo = MongoRepo.new
  repo.prepare_collections
  documents = data.map { |r| { email: r[:email] } }

  Benchmark.bm do |x|
    r = x.report('batch insert:') do
      repo.bm_insert(USERS, documents)
    end

    r_c = x.report('clustered batch insert:') do
      repo.bm_insert(CLUSTER_USERS, documents)
    end

    File.open(REPORT_FILE, 'a') do |f|
      f.write("clustered batch insert: #{r_c}")
      f.write("batch insert: #{r}")
    end
  end

  # reverse order to compare the performance
  Benchmark.bm do |x|
    r = x.report('batch insert:') do
      repo.bm_insert(USERS, documents)
    end

    r_c = x.report('clustered batch insert:') do
      repo.bm_insert(CLUSTER_USERS, documents)
    end

    File.open(REPORT_FILE, 'a') do |f|
      f.write("clustered batch insert: #{r_c}")
      f.write("batch insert: #{r}")
    end
  end
end
