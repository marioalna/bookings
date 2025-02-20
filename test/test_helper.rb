ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    def log_in_admin
      post session_path, params: { email: 'admin2@test.com', password: 'testme' }
    end

    def log_in_user
      post session_path, params: { email: 'regular2@test.com', password: 'testme' }
    end

    # Add more helper methods to be used by all tests here...
  end
end
