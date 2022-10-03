require 'csv'
require 'date'
require 'time'
require 'active_support'
require 'active_support/core_ext'

class CsvValidator
  attr_reader :errors

  def initialize(file_path, table_info, locales: [])
    @table_info = table_info
    @file_path = file_path
    @csv = CSV.table(file_path, { header_converters: ->(header) { header.to_s } })
    @errors = []
    @rule_null_col = @table_info.not_null_columns
    @rule_timestamp_col = @table_info.timestamp_columns
    p @rule_length_limit = @table_info.length_limit_data(@csv.headers)
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
  end

  # TODO, implement any private methods you need
  private

  def test_empty(_data)
    p @errors << 'Empty Content' if _data.empty?
  end

  def test_duplicate_id(_data)
    repeat = _data['id'].select do |x|
      _data['id'].count(x) > 1
    end
    repeat.uniq.each do |x|
      @errors << "Duplicate Ids: [#{x}]"
    end
  end

  def test_limit_rule(_data, test_col)
    test_col.each do |x|
      col = x[0]
      limit_length = x[1]
      if _data[col].length > limit_length
        @errors << "Length Limit Violation at #{col}(#{limit_length}) in Row ID=#{_data['id']}"
      end
    end
  end

  def test_null_rule(_data, test_col)
    test_col.each do |x|
      @errors << "Not Null Violation at #{x} in Row ID=#{_data['id']}" if _data[x].nil?
    end
  end

  def test_datetime_rule(_data, _test_col)
    _test_col.each do |x|
      next unless _data[x].present?

      begin
        DateTime.strptime("#{_data[x]}", '%Y-%m-%d %H:%M:%S')
      rescue StandardError
        @errors << "Time Format Violation at #{x} in Row ID=#{_data['id']}"
      end
    end
  end
end
