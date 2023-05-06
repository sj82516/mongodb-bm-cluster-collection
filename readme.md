# MongoDB Clustered Collection Benchmark
based on this article [](https://medium.com/@hnasr/mongodb-internal-architecture-9a32f1403d6f), MongoDB support 
clustered collection since 5.3 

Write down some benchmark to test the performance of clustered collection.

## Test Environment
- GCP e2-standard-4 (4 vCPUs, 16 GB memory)
- MongoDB 6.0 standalone without any configuration

## Benchmark
Test clustered index and secondary index performance on clustered collection and normal collection.
1. `bm.rb` test the CRD performance on clustered collection.  
a. insert 1000000 documents into clustered collection  
b. find 100000 documents collection by _id and email
c. delete 100000 documents collection by _id and email
2. `bm_uuid.rb` test whether the uuid as _id will affect the performance of clustered collection.

## Observation
1. 
