# frozen_string_literal: true
# This benchmark is for comparing the performance
# of the MongoDB clustered collection and normal collection
# https://www.mongodb.com/docs/upcoming/core/clustered-collections/

require 'benchmark'
include Benchmark

require_relative './mongo'
require_relative './generator'

n = 1e6.to_i
prepare_clustered_collection
prepare_normal_collection
gen = GenData.new

10.times.each do
  Benchmark.bm do |x|
    emails = n.times.map { Faker::Internet.email }
    ids = gen.gen_ids(n)

    data = ids.zip(emails)
    x.report('clustered batch insert:') do
      bm_insert!(CLUSTER_USERS, data)
    end

    x.report('batch insert:') do
      bm_insert!(USERS, data)
    end

    pp "-----------"
    search_size = n / 10
    search_ids = ids.sample(search_size).shuffle
    x.report('clustered find by id:') do
      bm_find(CLUSTER_USERS, search_ids, nil)
    end
    x.report('find by id:') do
      bm_find(USERS, search_ids, nil)
    end

    pp "-----------"
    search_emails = emails.sample(search_size).shuffle
    x.report('clustered find by email:') do
      bm_find(CLUSTER_USERS, nil, search_emails)
    end
    x.report('find by email:') do
      bm_find(USERS, nil, search_emails)
    end

    pp "-----------"
    delete_size = n / 100
    delete_ids = ids.sample(delete_size).shuffle
    x.report('clustered delete by id:') do
      bm_delete(CLUSTER_USERS, delete_ids, nil)
    end
    x.report('delete by id:') do
      bm_delete(USERS, delete_ids, nil)
    end

    pp "-----------"
    delete_emails = emails.sample(delete_size).shuffle
    x.report('clustered delete by email:') do
      bm_delete(CLUSTER_USERS, nil, delete_emails)
    end
    x.report('delete by email:') do
      bm_delete(USERS, nil, delete_emails)
    end

    pp "==========="
  end
end
