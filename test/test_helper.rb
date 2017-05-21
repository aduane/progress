# frozen_string_literal: true

require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'mocha/mini_test'

module ActiveSupport
  class TestCase
    fixtures :all

    def teardown
      Redis.new.flushdb
    end
  end
end
