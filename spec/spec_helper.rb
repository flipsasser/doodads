# frozen_string_literal: true

require "bundler/setup"

ENV["RAILS_ENV"] ||= "test"
require File.expand_path("./fixtures/dummy/config/environment", __dir__)
require "rspec/rails"
Dir[Rails.root.join("spec", "support", "**", "*.rb")].sort.each { |f| require f }

require "simplecov"
SimpleCov.start

require "doodads"
require "doodads/railtie"

RSpec.configure do |config|
  config.filter_rails_from_backtrace!
  config.use_active_record = false
  config.example_status_persistence_file_path = ".rspec_status"
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
