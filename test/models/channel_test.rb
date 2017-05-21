# frozen_string_literal: true

require 'test_helper'

class ChannelTest < ActiveSupport::TestCase
  test '#channel_redis_key' do
    channel = Channel.new
    assert_equal "channel:#{channel.name}", channel.channel_redis_key
  end

  test '#task_list_redis_key' do
    channel = Channel.new
    assert_equal "channel:#{channel.name}:tasks", channel.task_list_redis_key
  end

  test '#api_key_redis_key' do
    channel = Channel.new
    assert_equal "api_key:#{channel.api_key}", channel.api_key_redis_key
  end

  test '::create' do
    assert_difference -> { Redis.new.keys.count }, 3 do
      @channel = Channel.create
    end
    assert Redis.new.get(@channel.channel_redis_key)
    assert Redis.new.llen(@channel.task_list_redis_key)
    assert Redis.new.get(@channel.api_key_redis_key)
  end
end
