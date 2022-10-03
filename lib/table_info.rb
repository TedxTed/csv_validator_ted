# frozen_string_literal: true

require 'active_support'
require 'active_support/core_ext'

class TableInfo
  attr_reader :localized_header_pattern, :timestamp_columns, :not_null_columns

  def initialize(schema)
    @schema = schema
    @timestamp_columns = []
    @not_null_columns = []
    @limit_rules = []
    parse_schema(@schema)
    # TODO, add any initialize process if you need
  end

  def length_limit_data(_headers)
    # TODO
    localized_header = _headers.select { |x| x.match(/\[/) }
    localized_header.each do |header|
      search = header.split('[')[0]
      limit_num = @schema["#{search}"][:limit] || 255
      @limit_rules << [header, limit_num]
    end
    @limit_rules
  end

  # TODO, implement any private methods you need
  private

  def parse_schema(schema)
    schema.each do |item|
      col_name = item[0]
      col_type = item[1][:type]
      col_limit = item[1][:limit]
      col_null  = item[1][:null]
      col_auto_increment = item[1][:auto_increment]
      col_default = item[1][:default]

      timestamp_col(col_name, col_type)
      null_col(col_name, col_auto_increment, col_null, col_default)
    end
  end

  def null_col(name, _auto_increment, null, default)
    @not_null_columns << name if null == false && !_auto_increment && default.nil?
  end

  def timestamp_col(name, type)
    @timestamp_columns << name if %w[datetime timestamp].include?(type)
  end
end
