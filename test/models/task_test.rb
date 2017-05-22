# frozen_string_literal: true

require 'test_helper'

class TaskTest < ActiveSupport::TestCase
  context '::new' do
    context 'with params' do
      setup do
        @params = { label: 'my cool task',
                    numerator: 0,
                    denominator: 2,
                    idle_expiration_duration: '1 hour',
                    unit: 'steps' }
      end

      should 'assign the params' do
        task = Task.new(@params)
        assert_equal @params[:label], task.label
        assert_equal @params[:numerator], task.numerator
        assert_equal @params[:denominator], task.denominator
        assert_equal 60 * 60,
                     task.idle_expiration_duration
        assert_equal @params[:unit], task.unit
        assert_not_nil task.id
      end
    end

    context 'without params' do
      should 'set default values' do
        task = Task.new
        assert_equal 'Untitled Task', task.label
        assert_equal 0, task.numerator
        assert_equal 1, task.denominator
        # 3 days
        assert_equal 3 * 60 * 60 * 24,
                     task.idle_expiration_duration
        assert_equal 'things', task.unit
        assert_not_nil task.id
      end
    end
  end

  context '#numerator=' do
    should 'set it to the given number' do
      task = Task.new
      task.numerator = 9
      assert_equal 9, task.numerator
      task.numerator = '4'
      assert_equal 4, task.numerator
    end

    should 'default to 0' do
      task = Task.new
      task.numerator = nil
      assert_equal 0, task.numerator
      task.numerator = 'socks'
      assert_equal 0, task.numerator
    end

    should 'not allow negative values' do
      task = Task.new
      task.numerator = -3
      assert_equal 0, task.numerator
    end
  end

  context '#denominator=' do
    should 'set it to the given number' do
      task = Task.new
      task.denominator = 9
      assert_equal 9, task.denominator
      task.denominator = '4'
      assert_equal 4, task.denominator
    end

    should 'default to 1' do
      task = Task.new
      task.denominator = nil
      assert_equal 1, task.denominator
      task.denominator = 'socks'
      assert_equal 1, task.denominator
    end

    should 'not allow negative values' do
      task = Task.new
      task.denominator = -3
      assert_equal 1, task.denominator
    end
  end

  context '#idle_expiration_duration=' do
    should 'look up the duration in seconds for valid durations' do
      task = Task.new
      Task::IDLE_EXPIRATION_DURATIONS.keys.each do |duration|
        task.idle_expiration_duration = duration
        assert_equal Task::IDLE_EXPIRATION_DURATIONS[duration],
                     task.idle_expiration_duration
      end
    end

    should 'default to 3 days' do
      task = Task.new
      task.idle_expiration_duration = nil
      assert_equal Task::IDLE_EXPIRATION_DURATIONS['3 days'],
                   task.idle_expiration_duration
      task.idle_expiration_duration = '10 fortnights'
      assert_equal Task::IDLE_EXPIRATION_DURATIONS['3 days'],
                   task.idle_expiration_duration
    end
  end

  context '#redis_key' do
    should 'be the key for the hash that holds the attributes in redis' do
      task = Task.new api_key: '123abc'
      assert_equal "task:123abc:#{task.id}", task.redis_key
    end
  end

  context 'channel_name' do
    setup do
      @channel = Channel.create
      @task = Task.new(label: 'my cool task',
                       numerator: 4,
                       denominator: 10,
                       idle_expiration_duration: '1 hour',
                       unit: 'steps',
                       api_key: @channel.api_key).save
    end

    should 'be the channel associated with the api key' do
      assert_equal @channel.name, @task.channel_name
    end
  end

  context '#status' do
    should 'be a human readable description of the progress' do
      task = Task.new label: 'cool task', numerator: 1, denominator: 2
      assert_equal '\'cool task\' is 50.0% complete', task.status
    end
  end

  context 'progress update methods' do
    setup do
      @channel = Channel.create
      @task = Task.new(label: 'my cool task',
                       numerator: 4,
                       denominator: 10,
                       idle_expiration_duration: '1 hour',
                       unit: 'steps',
                       api_key: @channel.api_key).save
    end

    context '#overwrite_numerator' do
      should 'update the numerator in the redis hash to the given value' do
        @task.overwrite_numerator 6
        assert_equal 6, Task.find(@channel.api_key, @task.id).numerator
        @task.overwrite_numerator '3'
        assert_equal 3, Task.find(@channel.api_key, @task.id).numerator
        @task.overwrite_numerator 'socks'
        assert_equal 0, Task.find(@channel.api_key, @task.id).numerator
      end
    end

    context '#increment_numerator_by' do
      should 'increment the numerator field in the redis hash' do
        @task.increment_numerator_by 1
        assert_equal 5, Task.find(@channel.api_key, @task.id).numerator
        @task.increment_numerator_by '3'
        assert_equal 8, Task.find(@channel.api_key, @task.id).numerator
        @task.increment_numerator_by 'socks'
        assert_equal 8, Task.find(@channel.api_key, @task.id).numerator
      end

      should 'not let the redis value be greater than the denominator' do
        @task.increment_numerator_by 20
        assert_equal 10, Task.find(@channel.api_key, @task.id).numerator
        assert_equal '10', Redis.new.hmget(@task.redis_key, 'numerator').first
      end
    end

    context '#decrement_numerator_by' do
      should 'decrement the numerator field de the redis hash' do
        @task.decrement_numerator_by 1
        assert_equal 3, Task.find(@channel.api_key, @task.id).numerator
        @task.decrement_numerator_by '2'
        assert_equal 1, Task.find(@channel.api_key, @task.id).numerator
        @task.decrement_numerator_by 'socks'
        assert_equal 1, Task.find(@channel.api_key, @task.id).numerator
      end

      should 'not let the redis value be negative' do
        @task.decrement_numerator_by 20
        assert_equal 0, Task.find(@channel.api_key, @task.id).numerator
        assert_equal '0', Redis.new.hmget(@task.redis_key, 'numerator').first
      end
    end
  end

  context '#save' do
    setup do
      @channel = Channel.create
      @task = Task.new(label: 'my cool task',
                       numerator: 0,
                       denominator: 2,
                       idle_expiration_duration: '1 hour',
                       unit: 'steps',
                       api_key: @channel.api_key)
    end

    should 'write the attrs to a redis hash' do
      assert_difference -> { Redis.new.keys.count }, 1 do
        @task.save
      end

      task_attr_hash = Redis.new.hgetall(@task.redis_key)
      assert_equal @task.label, task_attr_hash['label']
      assert_equal @task.numerator, task_attr_hash['numerator'].to_i
      assert_equal @task.denominator, task_attr_hash['denominator'].to_i
      assert_equal @task.unit, task_attr_hash['unit']
      assert_equal @task.idle_expiration_duration,
                   task_attr_hash['idle_expiration_duration'].to_i
    end

    should 'add the task id to the task list of the channel for the api key' do
      assert_difference -> { @channel.task_list.count }, 1 do
        @task.save
      end
      assert @channel.task_list.include?(@task.id)
    end
  end
end
