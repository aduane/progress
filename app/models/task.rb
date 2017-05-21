# frozen_string_literal: true

require 'securerandom'

# A task is something that we can record progress about
class Task
  attr_accessor :label, :numerator, :denominator,
                :idle_expiration_duration, :unit, :id, :api_key

  IDLE_EXPIRATION_DURATIONS = { '5 minutes' => 300, '10 minutes' => 600,
                                '20 minutes' => 1200, '30 minutes' => 1800,
                                '1 hour' => 3600, '2 hours' => 7200,
                                '5 hours' => 18_000, '12 hours' => 43_200,
                                '1 day' => 86_400, '2 days' => 172_800,
                                '3 days' => 259_200,
                                '1 week' => 604_800 }.freeze

  def self.find(api_key, task_id)
    found_attrs = redis.hgetall(redis_key(api_key, task_id))
                       .with_indifferent_access
    new(found_attrs.merge(id: task_id, api_key: api_key)) if found_attrs
  end

  def initialize(params = {})
    self.label = params[:label] || 'Untitled Task'
    self.numerator = params[:numerator]
    self.denominator = params[:denominator]
    self.idle_expiration_duration = params[:idle_expiration_duration]
    self.unit = params[:unit] || 'things'
    self.id = params[:id] || generate_id
    self.api_key = params[:api_key]
  end

  def idle_expiration_duration=(duration_in_words)
    @idle_expiration_duration = IDLE_EXPIRATION_DURATIONS[duration_in_words] ||
                                IDLE_EXPIRATION_DURATIONS['3 days']
  end

  def numerator=(numerator)
    # If the value as an int is at least 0, use it. Use 0 otherwise.
    @numerator = numerator.to_i >= 0 ? numerator.to_i : 0
  end

  def denominator=(denominator)
    # If the value as an int is greater than zero, use it. Use 1 otherwise.
    @denominator = denominator.to_i.positive? ? denominator.to_i : 1
  end

  def save
    redis.mapped_hmset(redis_key,
                       label: label, numerator: numerator,
                       denominator: denominator, unit: unit,
                       idle_expiration_duration: idle_expiration_duration)
    Channel.add_task_to_channel(api_key, id)
    self
  end

  def as_json(options = { include_id: false })
    json = { status: status }
    json[:task_id] = id if options[:include_id]
    json
  end

  def status
    "'#{label}' is #{progress_as_percentage} complete"
  end

  def redis_key
    Task.redis_key api_key, id
  end

  private_class_method
  def self.redis_key(api_key, id)
    "task:#{api_key}:#{id}"
  end

  private_class_method
  def self.redis
    @redis ||= Redis.new
  end

  private

  def progress_as_percentage
    "#{((numerator.to_f / denominator.to_f) * 100).round(1)}%"
  end

  def redis
    @redis ||= Redis.new
  end

  def generate_id
    SecureRandom.uuid
  end
end
