# frozen_string_literal: true

require "simplecov"
SimpleCov.start do
  add_filter "spec/"
end

ENV["RAILS_ENV"] ||= "test"
require "bundler/setup"
require File.expand_path("./fixtures/dummy/config/environment", __dir__)
require "rspec/rails"
Dir[Rails.root.join("spec", "support", "**", "*.rb")].sort.each { |f| require f }

require "doodads"
require "doodads/railtie"

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.disable_monkey_patching!
  config.example_status_persistence_file_path = ".rspec_status"
  config.filter_rails_from_backtrace!
  # config.filter_run focus: true
  config.use_active_record = false

  config.after do |example|
    unless example.metadata[:clear] == false
      Doodads::Components.registry.clear
      Doodads::Components.constants.each { |const| Doodads::Components.send(:remove_const, const) }
      Doodads::Flags.clear
      Doodads::Strategies.all.clear
    end
  end
end
