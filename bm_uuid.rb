# frozen_string_literal: true
# This benchmark is for comparing the performance
# of the MongoDB clustered collection and normal collection
# https://www.mongodb.com/docs/upcoming/core/clustered-collections/

require 'benchmark'
include Benchmark

require_relative './bm_cluster_collection'
require_relative './generator'

n = 1e7.to_i
client = mongo_client
bm = BmClusterCollection.new(client)
bm.prepare_collections
gen = GenData.new

Benchmark.bm do |x|
  emails = n.times.map { Faker::Internet.email }
  ids = gen.gen_uuids(n)

  data = ids.zip(emails)
  x.report('clustered batch insert:') do
    bm.bm_insert!(CLUSTER_USERS, data)
  end

  x.report('batch insert:') do
    bm.bm_insert!(USERS, data)
  end
end
