# frozen_string_literal: true

# This handles the task lifecycle
class TasksController < ApplicationController
  # POST /tasks
  def create
    @task = Task.new(params).save
    respond_to do |format|
      format.json { render json: @task.to_json(include_id: true) }
    end
  end
end
