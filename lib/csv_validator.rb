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
    # TODO, add any initialize process if you need
  end

  def valid?
    # TODO
  end

  # TODO, implement any private methods you need

end
