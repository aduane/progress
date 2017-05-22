# frozen_string_literal: true

# actioncable channel to handle progress bar lifecycle events
class ProgressChannel < ApplicationCable::Channel
  def subscribed
    stream_from params[:name]
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
