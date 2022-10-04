require 'csv'
require 'date'
require 'time'
require 'active_support'
require 'active_support/core_ext'

class CsvValidator
  attr_reader :errors

  def initialize(file_path, table_info)
    @table_info = table_info
    @file_path = file_path
    @csv = CSV.table(file_path, { header_converters: ->(header) { header.to_s } })
    @errors = []
    @rule_null_col = @table_info.not_null_columns
    @rule_timestamp_col = @table_info.timestamp_columns
    @rule_length_limit = @table_info.length_limit_data(@csv.headers)
    # TODO, add any initialize process if you need
  end

  def valid?
    test_empty(@csv)
    test_duplicate_id(@csv)
    @csv.each do |row|
      test_null_rule(row, @rule_null_col)
      test_datetime_rule(row, @rule_timestamp_col)
      test_limit_rule(row, @rule_length_limit)
    end
    @errors.length <= 0
  end

  # TODO, implement any private methods you need
  private

  def test_empty(data)
    @errors << 'Empty Content' if data.empty?
  end

  def test_duplicate_id(data)
    repeat = data['id'].select do |id|
      data['id'].count(id) > 1
    end
    repeat.uniq.each do |id|
      @errors << "Duplicate Ids: [#{id}]"
    end
  end

  def test_limit_rule(data, test_col)
    test_col.each do |col|
      col_name = col[0]
      limit_length = col[1]
      if data[col_name].length > limit_length
        @errors << "Length Limit Violation at #{col_name}(#{limit_length}) in Row ID=#{data['id']}"
      end
    end
  end

  def test_null_rule(data, test_col)
    test_col.each do |col|
      @errors << "Not Null Violation at #{col} in Row ID=#{data['id']}" if data[col].nil?
    end
  end

  def test_datetime_rule(data, test_col)
    test_col.each do |col|
      next unless data[col].present?

      begin
        DateTime.strptime(data[col], '%Y-%m-%d %H:%M:%S')
      rescue StandardError
        @errors << "Time Format Violation at #{col} in Row ID=#{data['id']}"
      end
    end
  end
end
