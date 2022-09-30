# frozen_string_literal: true

require 'table_info'

RSpec.describe TableInfo do
  let(:info) { described_class.new(schema) }
  let(:table_name) { 'cards' }
  let(:locales) { %w[en fr] }
  let(:schema) { nil }

  describe 'timestamp_columns' do
    subject { info.timestamp_columns }

    let(:schema) do
      {
        'start_at' => { type: 'integer' },
        'end_at' => { type: 'timestamp' },
        'open_at' => { type: 'datetime' }
      }
    end

    it 'returns array of column names' do
      expect(subject).to be_kind_of(Array)
    end

    it 'detected time field based on type definition in schema' do
      is_expected.to eq %w[end_at open_at]
    end
  end

  describe 'not_null_columns' do
    subject { info.not_null_columns }

    let(:schema) do
      {
        'id' => { null: false, auto_increment: true },
        'area_id' => { null: false },
        'name' => { null: false },
        'character_id' => { null: true },
        'sp_type' => { null: false, default: 1 }
      }
    end

    it 'returns array of column names' do
      expect(subject).to be_kind_of(Array)
    end

    context 'column which is not allowed null' do
      it { is_expected.to include 'area_id' }
      it { is_expected.to include 'name' }

      context 'but auto-increment' do
        it { is_expected.not_to include 'id' }
      end

      context 'but defined default value' do
        it { is_expected.not_to include 'sp_type' }
      end
    end

    context 'column which is allowed null' do
      it { is_expected.not_to include 'character_id' }
    end
  end

  # Hint: 參考 README 備註[2]
  describe '#length_limit_data' do
    subject { info.length_limit_data(csv_headers) }
    let(:csv_headers) { ['name[en]', 'name[zh]', 'description[en]', 'description[zh]', 'conditions'] }
    let(:schema) do
      {
        'name' => { type: 'string', limit: 80 },
        'description' => { type: 'string', limit: 255 },
        'conditions' => { limit: 30 }
      }
    end

    it 'returns csv header names of localized fields with their length limit' do
      is_expected.to eq [
        ['name[en]', 80],
        ['name[zh]', 80],
        ['description[en]', 255],
        ['description[zh]', 255]
      ]
    end

    it 'returns localized fields only' do
      field_names = subject.map(&:first)
      expect(field_names).not_to include 'condition'
    end

    context 'string column but no limit value defined in the schema' do
      let(:schema) do
        {
          'name' => { type: 'string' },
          'description' => { type: 'string', limit: 120 },
          'conditions' => { limit: 30 }
        }
      end

      it 'defaults limit to 255' do
        is_expected.to eq [
          ['name[en]', 255],
          ['name[zh]', 255],
          ['description[en]', 120],
          ['description[zh]', 120]
        ]
      end
    end
  end
end

