require 'csv'
require 'active_support'
require 'active_support/core_ext'

class CsvValidator
  attr_reader :errors

  def initialize(file_path, table_info, locales: [])
    @table_info = table_info
    @csv = CSV.table(file_path, { header_converters: lambda { |header| header.to_s } })
    @errors = []
    # TODO, add any initialize process if you need
  end

  def valid?
    # TODO
    true
  end

  private

  # TODO, implement any private methods you need
end

