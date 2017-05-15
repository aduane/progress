# frozen_string_literal: true

# Base AR class
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end
