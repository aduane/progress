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

  test '#task_list' do
    channel = Channel.create
    Redis.current.lpush channel.task_list_redis_key, '123abc'
    assert_equal Redis.current.lrange(channel.task_list_redis_key, 0, -2),
                 channel.task_list
  end

  test '#tasks' do
    channel = Channel.create
    task1 = Task.new(label: 'my cool task',
                     numerator: 0,
                     denominator: 2,
                     unit: 'steps',
                     api_key: channel.api_key).save
    task2 = Task.new(label: 'my other task',
                     numerator: 1,
                     denominator: 3,
                     unit: 'steps',
                     api_key: channel.api_key).save
    assert_includes channel.tasks.map(&:id), task1.id
    assert_includes channel.tasks.map(&:id), task2.id
  end

  test '::create' do
    assert_difference -> { Redis.current.keys.count }, 3 do
      @channel = Channel.create
    end
    assert Redis.current.get(@channel.channel_redis_key)
    assert Redis.current.llen(@channel.task_list_redis_key)
    assert Redis.current.get(@channel.api_key_redis_key)
  end

  test '::find' do
    channel = Channel.create
    found_channel = Channel.find(channel.name)
    assert_equal channel.name, found_channel.name
    assert_equal channel.task_list_redis_key, found_channel.task_list_redis_key
  end

  test '::add_task_to_channel' do
    channel = Channel.create
    assert_difference -> { channel.task_list.count }, 1 do
      Channel.add_task_to_channel(channel.api_key, '123abc')
    end
    assert_equal ['123abc'], channel.task_list
  end
end
