require 'securerandom'
require 'faker'
require 'bson'

# generate random data for benchmark
class DataService
  OUTPUT_FILE = 'data.txt'

  def gen_data(n)
    gen = GenData.new
    File.delete(OUTPUT_FILE) if File.exist?(OUTPUT_FILE)

    patch_size = 1000
    times = n / patch_size
    patch_size.times do |i|
      pp "patch #{i}"
      File.open(OUTPUT_FILE, 'a') do |f|
        emails = gen.gen_emails(times)
        bson_ids = gen.gen_bson_id(times)
        uuids = gen.gen_uuids(times)

        zip_data = emails.zip(bson_ids, uuids)
        data = zip_data.map do |r|
          "#{r[0]}\t#{r[1]}\t#{r[2]}"
        end.join("\n")

        f.write(data)
      end
    end
  end

  def read_data_in_page(total, page_size)
    start_index = 0
    data = []
    File.open(OUTPUT_FILE, 'r').each do |line|
      line = line.chomp.split("\t")
      data << {
        email: line[0],
        bson_id: line[1],
        uuid: line[2]
      }

      if data.size == page_size
        yield data
        start_index += data.size
        break if start_index >= total
        data = []
      end
    end
  end
end

class GenData
  def initialize
    @id_map = {}
  end

  def gen_bson_id(n)
    gen_ids(n, -> { BSON::ObjectId.new })
  end

  def gen_uuids(n)
    gen_ids(n, -> { SecureRandom.uuid })
  end

  def gen_emails(n)
    emails = []
    run_in_parallel(->() {
      (n / CON_NUM).times.map do
        email = Faker::Internet.email
        emails << email
      end
    })

    emails
  end

  CON_NUM = 4

  private

  def gen_ids(n, id_gen)
    semaphore = Mutex.new
    ids = []
    run_in_parallel(->() {
      (n / CON_NUM).times.map do
        id = id_gen.call
        semaphore.synchronize do
          while @id_map[id.to_s]
            id = id_gen
          end

          @id_map[id.to_s] = true
          ids << id
        end

      end
    })

    ids
  end

  def run_in_parallel(exec_func)
    con_num = CON_NUM

    threads = []

    con_num.times do |i|
      threads << Thread.new do
        exec_func.call
      end
    end

    threads.each(&:join)
  end
end
