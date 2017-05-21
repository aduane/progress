# frozen_string_literal: true

# This handles channel creation and viewing
class ChannelsController < ApplicationController
  # GET /started
  def create
    @channel = Channel.create
    respond_to do |format|
      format.json { render json: @channel }
    end
  end

  # GET /channels/:name
  def show
    channel = Channel.find(params[:name])
    @tasks = channel.tasks
    if channel
    else
      redirect_to root_url, status: 404
    end
  end
end
