require_relative 'environment'
require 'api'

use ActiveRecord::ConnectionAdapters::ConnectionManagement
use Rack::Cors do
  allow do
    origins '*'
    resource '*', headers: :any, methods: %i(post get delete)
  end
end

run FizzBuzz::API
