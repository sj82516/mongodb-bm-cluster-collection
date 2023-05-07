# MongoDB Clustered Collection Benchmark
based on this article [](https://medium.com/@hnasr/mongodb-internal-architecture-9a32f1403d6f), MongoDB support 
clustered collection since 5.3 

Write down some benchmark to test the performance of clustered collection.

## Test Environment
- GCP e2-standard-4 (4 vCPUs, 16 GB memory)
- MongoDB 6.0 standalone without any configuration

## Benchmark
Test clustered index and secondary index performance on clustered collection and normal collection.
1. bm/insert.rb: each time insert 1e6 documents, total insert 2e7 documents into clustered collection and normal collection.
2. bm/uuid_insert.rb: each time insert 1e6 documents, one with uuid as _id, total insert 1e7 documents into clustered 
   collections

## Observation
1. Insert performance of clustered collection is better than normal collection, but not much.
![](./result/insert.png)
2. Insert performance of clustered collection with uuid as _id is worse than normal collection.
![](./result/uuid.png)
3. secondary index performance of clustered collection is larger than normal collection.
![](./result/sec.png)
4. I found out some performance issue when using find with multiple id search in clustered collection. related issue [Performance Issue about Clustered Collection : where there are more than one _id search condition, the search would fallback to COLLSCAN](https://jira.mongodb.org/browse/SERVER-76905)
