require 'csv_validator'

RSpec.describe CsvValidator do
  let(:validator) do
    described_class.new(file_path, table_info)
  end
  let(:file_path) { file_fixture_path('csv/happy_case.csv') }
  let(:schema) do
    {
      'id' => { type: 'integer', auto_increament: true, null: false },
      'name' => { type: 'string', null: true, limit: 20 },
      'description' => { type: 'string', null: true, limit: 255 },
      'character_id' => { type: 'integer', null: false },
      'start_at' => { type: 'datetime' },
      'end_at' => { type: 'datetime' }
    }
  end
  let(:table_info) { TableInfo.new(schema) }
  let(:errors) { validator.errors }

  describe '#valid?' do
    subject { validator.valid? }

    context 'validation passed' do
      it { is_expected.to be_truthy }
      it 'collected no error' do
        subject
        expect(errors).to be_empty
      end
    end

    context 'validation failed' do
      context 'empty content' do
        let(:file_path) { file_fixture_path('csv/invalid_empty.csv') }
        it { is_expected.to be_falsey }
        it 'collected error messages of empty content' do
          subject
          expect(errors).to eq ['Empty Content']
        end
      end

      context 'duplicate id in data rows' do
        let(:file_path) { file_fixture_path('csv/invalid_duplicate.csv') }
        it { is_expected.to be_falsey }
        it 'collected error messages of duplicated IDs' do
          subject
          expect(errors).to eq ['Duplicate Ids: [2]']
        end
      end

      context 'contained missing value in a field which is not allowed null' do
        let(:file_path) { file_fixture_path('csv/invalid_not_null.csv') }
        it { is_expected.to be_falsey }
        it 'collected error messages of row(s) with field invalid by not allowed null' do
          subject
          expect(errors).to eq ['Not Null Violation at character_id in Row ID=1']
        end
      end

      context 'row data contained invalid time format' do
        let(:file_path) { file_fixture_path('csv/invalid_timestamp.csv') }
        it { is_expected.to be_falsey }
        it 'collected error messages of row(s) with field invalid by time format' do
          subject
          expect(errors).to eq [
            'Time Format Violation at start_at in Row ID=2',
            'Time Format Violation at end_at in Row ID=3'
          ]
        end
      end

      context 'contained data which is string but exceed the lengh limit of column' do
        let(:file_path) { file_fixture_path('csv/invalid_length.csv') }
        it { is_expected.to be_falsey }
        it 'collected error messages of row(s) with field invalid by length limitation' do
          subject
          expect(errors).to eq ["Length Limit Violation at name[en](20) in Row ID=2"]
        end
      end
    end
  end
end

