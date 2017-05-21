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

  # PUT /tasks/:id
  def update
    @task = Task.find(params[:api_key], params[:id])
    if @task
      update_task(params.slice(:increment_by, :decrement_by, :numerator))
      respond_to { |format| format.json { render json: @task } }
    else
      respond_to do |format|
        format.json { render json: { error: 'Task not found.' }, status: 404 }
      end
    end
  end

  private

  def update_task(update_params)
    # Yep, we choose for you if you send multiple update params
    if update_params[:numerator]
      @task.overwrite_numerator(update_params[:numerator])
    elsif update_params[:increment_by]
      @task.increment_numerator_by(update_params[:increment_by])
    elsif update_params[:decrement_by]
      @task.decrement_numerator_by(update_params[:decrement_by])
    end
  end
end
