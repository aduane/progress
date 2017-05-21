# frozen_string_literal: true

require 'test_helper'

class ChannelsControllerTest < ActionDispatch::IntegrationTest
  test 'GET /started should create a channel' do
    get '/started', as: :json
    assert_response :success
    assert_equal assigns(:channel).api_key, JSON.parse(response.body)['api_key']
    assert_equal assigns(:channel).name,
                 JSON.parse(response.body)['channel_name']
  end
end
