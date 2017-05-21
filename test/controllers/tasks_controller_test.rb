# frozen_string_literal: true

require 'test_helper'

class TasksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @label = 'my test run'
    @numerator = 2
    @denominator = 5
    @unit = 'tests'
    @channel = Channel.create
    @api_key = @channel.api_key
  end

  test 'POST /tasks should create a task and add it to the channel' do
    post tasks_url, params: { label: @label,
                              numerator: @numerator,
                              denominator: @denominator,
                              unit: @unit,
                              api_key: @api_key }, as: :json
    assert_response :success
    assert_equal assigns(:task).status, JSON.parse(response.body)['status']
    assert_equal assigns(:task).id, JSON.parse(response.body)['task_id']
    assert_equal [assigns(:task).id], @channel.task_list
  end

  context 'PUT /tasks' do
    setup do
      @task = Task.new(label: @label,
                       numerator: @numerator,
                       denominator: @denominator,
                       unit: @unit,
                       api_key: @api_key).save
    end

    should 'update by incrementing' do
      assert_difference -> { Task.find(@api_key, @task.id).numerator }, 2 do
        put task_url(id: @task.id), params: { api_key: @api_key,
                                              increment_by: 2 }, as: :json
      end
    end

    should 'update by decrementing' do
      assert_difference -> { Task.find(@api_key, @task.id).numerator }, -1 do
        put task_url(id: @task.id), params: { api_key: @api_key,
                                              decrement_by: 1 }, as: :json
      end
    end

    should 'update by setting a new numerator' do
      put task_url(id: @task.id), params: { api_key: @api_key,
                                            numerator: 1 }, as: :json
      updated_task = Task.find(@api_key, @task.id)
      assert_equal 1, updated_task.numerator
    end

    should 'not update other values' do
      put task_url(id: @task.id), params: { api_key: @api_key,
                                            label: 'modified label',
                                            denominator: 123,
                                            unit: 'dogs' }, as: :json
      updated_task = Task.find(@api_key, @task.id)
      assert_equal @label, updated_task.label
      assert_equal @denominator, updated_task.denominator
      assert_equal @unit, updated_task.unit
    end
  end
end
