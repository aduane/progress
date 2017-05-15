# frozen_string_literal: true

require 'test_helper'

class ChannelsControllerTest < ActionDispatch::IntegrationTest
  setup do
    Redis.new.flushdb
  end

  teardown do
    Redis.new.flushdb
  end

  test 'GET /started should create a channel' do
    previous_number_of_publishers =
      Redis.new.scan(0, match: 'channel*').last.count
    get '/started', as: :json
    assert_response :success
    current_number_of_publishers =
      Redis.new.scan(0, match: 'channel*').last.count
    assert_equal 1, current_number_of_publishers - previous_number_of_publishers
    assert_equal assigns(:channel).api_key, JSON.parse(response.body)['api_key']
    assert_equal assigns(:channel).name,
                 JSON.parse(response.body)['channel_name']
  end
end
