# frozen_string_literal: true

require 'active_support'
require 'active_support/core_ext'

class TableInfo
  attr_reader :localized_header_pattern

  def initialize(schema)
    @schema = schema
    # TODO, add any initialize process if you need
  end

  def timestamp_columns
    # TODO
  end

  def not_null_columns
    # TODO
  end

  def length_limit_data(headers)
    # TODO
  end

  private

  # TODO, implement any private methods you need
end

