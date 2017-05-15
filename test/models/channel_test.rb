# frozen_string_literal: true

require 'test_helper'

class ChannelTest < ActiveSupport::TestCase
  test '#redis_key' do
    channel = Channel.new
    assert_equal "channel:#{channel.name}", channel.redis_key
  end
end
