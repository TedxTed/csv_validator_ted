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
    !(@errors.length > 0)
  end

  # TODO, implement any private methods you need
  private

  def test_empty(_data)
    @errors << 'Empty Content' if _data.empty?
  end

  def test_duplicate_id(_data)
    repeat = _data['id'].select do |id|
      _data['id'].count(id) > 1
    end
    repeat.uniq.each do |id|
      @errors << "Duplicate Ids: [#{id}]"
    end
  end

  def test_limit_rule(_data, test_col)
    test_col.each do |col|
      col_name = col[0]
      limit_length = col[1]
      if _data[col_name].length > limit_length
        @errors << "Length Limit Violation at #{col_name}(#{limit_length}) in Row ID=#{_data['id']}"
      end
    end
  end

  def test_null_rule(_data, test_col)
    test_col.each do |col|
      @errors << "Not Null Violation at #{col} in Row ID=#{_data['id']}" if _data[col].nil?
    end
  end

  def test_datetime_rule(_data, _test_col)
    _test_col.each do |col|
      next unless _data[col].present?

      begin
        DateTime.strptime("#{_data[col]}", '%Y-%m-%d %H:%M:%S')
      rescue StandardError
        @errors << "Time Format Violation at #{col} in Row ID=#{_data['id']}"
      end
    end
  end
end
