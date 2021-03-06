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

  test 'GET /channels/channel-name should display the channel\'s tasks' do
    channel = Channel.create
    Task.new(label: 'task 1',
             numerator: 1,
             denominator: 2,
             unit: 'laps',
             api_key: channel.api_key).save
    Task.new(label: 'task 2',
             numerator: 3,
             denominator: 4,
             unit: 'bottles',
             api_key: channel.api_key).save
    get channel_path(name: channel.name)
    assert_response :success
    assert_equal 2, assigns(:tasks).size
  end

  test 'GETing a non-existant channel 404s' do
    get channel_path(name: 'this-channel-does-not-exist')
    assert_response :not_found
    assert response.body.include? 'Sorry!'
    assert response.body.include? 'We couldn\'t find that channel.'
  end
end
