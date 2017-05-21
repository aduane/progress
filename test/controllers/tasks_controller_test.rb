# frozen_string_literal: true

require 'test_helper'

class TasksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @label = 'my test run'
    @numerator = 0
    @denominator = 2
    @units = 'tests'
    @channel = Channel.create
    @api_key = @channel.api_key
  end

  test 'POST /tasks should create a task and add it to the channel' do
    post tasks_url, params: { label: @label,
                              numerator: @numerator,
                              denominator: @denominator,
                              units: @units,
                              api_key: @api_key }, as: :json
    assert_response :success
    assert_equal assigns(:task).status, JSON.parse(response.body)['status']
    assert_equal assigns(:task).id, JSON.parse(response.body)['task_id']
    assert_equal [assigns(:task).id], @channel.task_list
  end
end
