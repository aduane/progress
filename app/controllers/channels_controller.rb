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
end
