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
  ids = gen.gen_ids(n)

  data = ids.zip(emails)
  x.report('clustered batch insert:') do
    bm.bm_insert!(CLUSTER_USERS, data)
  end

  x.report('batch insert:') do
    bm.bm_insert!(USERS, data)
  end

  pp "-----------"
  search_size = n / 10
  search_ids = ids.sample(search_size).shuffle

  x.report('clustered find by id:') do
    bm.bm_find(CLUSTER_USERS, search_ids, nil)
  end
  x.report('find by id:') do
    bm.bm_find(USERS, search_ids, nil)
  end

  pp "-----------"
  search_emails = emails.sample(search_size).shuffle
  x.report('clustered find by email:') do
    bm.bm_find(CLUSTER_USERS, nil, search_emails)
  end
  x.report('find by email:') do
    bm.bm_find(USERS, nil, search_emails)
  end

  pp "-----------"
  delete_size = n / 100
  delete_ids = ids.sample(delete_size).shuffle
  x.report('clustered delete by id:') do
    bm.bm_delete(CLUSTER_USERS, delete_ids, nil)
  end
  x.report('delete by id:') do
    bm.bm_delete(USERS, delete_ids, nil)
  end

  pp "-----------"
  delete_emails = emails.sample(delete_size).shuffle
  x.report('clustered delete by email:') do
    bm.bm_delete(CLUSTER_USERS, nil, delete_emails)
  end
  x.report('delete by email:') do
    bm.bm_delete(USERS, nil, delete_emails)
  end
end
