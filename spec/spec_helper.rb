require 'simplecov'

$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "infrastrap"

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.filter_run :focus
  config.run_all_when_everything_filtered = true

  config.order = :random

  config.before :suite do
    FileUtils.mkdir_p(File.expand_path(__dir__) + "/../tmp")
    FileUtils.remove_dir(File.expand_path(__dir__) + "/../tmp/ansible", true)
    FileUtils.remove_dir(File.expand_path(__dir__) + "/../tmp/capistrano", true)
    FileUtils.remove_file(File.expand_path(__dir__) + "/../tmp/.gitignore", true)
    FileUtils.remove_file(File.expand_path(__dir__) + "/../tmp/Vagrantfile", true)
    FileUtils.remove_file(File.expand_path(__dir__) + "/../tmp/README.md", true)
    FileUtils.remove_file(File.expand_path(__dir__) + "/../tmp/ansible.cfg", true)
  end

  # def capture(stream)
  #   begin
  #     stream = stream.to_s
  #     eval "$#{stream} = StringIO.new"
  #     yield
  #     result = eval("$#{stream}").string
  #   ensure
  #     eval("$#{stream} = #{stream.upcase}")
  #   end
  #
  #   result
  # end
end

