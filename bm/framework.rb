
require 'benchmark'
require_relative '../utils/mongo_repo'

class BenchmarkFramework
  EXPERIMENT = 'experiment'

  CONTROL_NAME = 'control'
  CONTROL_COLLECTION = 'control'
  CONTROL_IS_CLUSTERED = false

  EXPERIMENT_NAME = 'experiment'
  EXPERIMENT_COLLECTION = 'experiment'
  EXPERIMENT_IS_CLUSTERED = false

  OUTPUT_FILE_NAME = 'bm_result.json'

  def initialize
    @experiment = self.class::EXPERIMENT
    @control_collection = self.class::CONTROL_COLLECTION
    @experiment_collection = self.class::EXPERIMENT_COLLECTION
    @output_file_name = self.class::OUTPUT_FILE_NAME
    @control_name = self.class::CONTROL_NAME
    @experiment_name = self.class::EXPERIMENT_NAME

    @repo = MongoRepo.new
    @repo.prepare_collection(@control_collection, self.class::CONTROL_IS_CLUSTERED)
    @repo.prepare_collection(@experiment_collection, self.class::EXPERIMENT_IS_CLUSTERED)
  end

  def run
    pre_run

    control_results = []
    experiment_results = []

    generate_data do |control_data, experiment_data|
      Benchmark.bm do |x|

        experiment_result = x.report(@experiment_name) do
          experiment_func(@repo, @experiment_collection, experiment_data)
        end
        experiment_results << experiment_result.real
        control_result = x.report(@control_name) do
          experiment_func(@repo, @control_collection, control_data)
        end
        control_results << control_result.real
      end
    end

    output_bm_result(File.join(__dir__, '../result' ,@output_file_name), control_results, experiment_results)
  end

  def pre_run
    # setup before run
  end

  def generate_data
    # provide data for control and experiment
    raise NotImplementedError
  end

  def experiment_func(repo, collection, data)
    # implement the experiment function
    raise NotImplementedError
  end

  private
  def output_bm_result(file_name, control_result, experiment_result)
    File.open(file_name, 'w') do |f|
      data = {
        experiment: @experiment,
        control_result: control_result,
        experiment_result: experiment_result,
        control_name: @control_name,
        experiment_name: @experiment_name,
      }
      f.puts(data.to_json)
    end
  end
end
