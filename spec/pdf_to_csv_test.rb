require 'spec_helper'
require './pdf_to_csv'

describe 'Test process to format an unformated CSV file into a formatted CSV file' do
  before :each do
    @file_name = './data/tabula-aeta_sample_p1.csv'
    @pdf_to_csv = PDFToCSV.new(@file_name)
  end

  describe PDFToCSV, '#initialize' do
    context 'when a new intance of PDFToCSV' do
      it 'should initialize @arr_headers_line_csv, @arr_age_rate_line_csv and @my_data' do
        expect(@pdf_to_csv).to be_an_instance_of(PDFToCSV)
        expect(@pdf_to_csv.arr_headers_line_csv).to be_instance_of(Array)
        expect(@pdf_to_csv.arr_age_rate_line_csv).to be_instance_of(Array)
        expect(@pdf_to_csv.my_data).to be_instance_of(Hash)
      end

      it 'should open file' do
        expect(@file_name).to eq('./data/tabula-aeta_sample_p1.csv')
        allow(File).to receive(:open).with(@file_name)
      end

      it 'should add line to either @arr_headers_line_csv or @arr_age_rate_line_csv' do
        expect(@pdf_to_csv.arr_headers_line_csv.length).to be > 0
        expect(@pdf_to_csv.arr_age_rate_line_csv.length).to be > 0
      end
    end
  end

  describe PDFToCSV, '#format_array' do
    context 'when is call by the class instance' do
      it 'should respond to format_array with 1 argument ' do
        expect(@pdf_to_csv).to respond_to(:format_array).with(1).argument
      end
    end
    context 'when Array is passed as argument' do
      let(:array) { ["CALIFORNIA,\r\n", "Rating Area:CARA01 *,\r\n", "Plan ID:14033847Plan,\r\n", "Age,Rate,\r\n"] }

      it 'should format the array' do
        expect(@pdf_to_csv.format_array(array)).to eql([["CALIFORNIA"], ["Rating Area:CARA01 *"], ["Plan ID:14033847Plan"], ["Age", "Rate"]])
      end
    end
    context 'when something different than an Array is passed as argument' do
      let(:string) { 'something' }

      it 'raise an error' do
        expect { @pdf_to_csv.format_array(string) }.to raise_error("Invalid Format")
      end
    end
  end

  describe PDFToCSV, '#add_description_data' do
    context 'when is call by the class instance ' do
      it 'should receive hash argument' do
        expect(@pdf_to_csv).to respond_to(:add_description_data).with(1).argument
      end

      it 'should populate @my_data hash' do
        @pdf_to_csv.add_description_data(rate:1,plan_id:123456,plan_name:"default", issuer_name:"aetna")
        expect(@pdf_to_csv.my_data.length).to be > 0
      end
    end
  end

  describe PDFToCSV, '#formatted_age_rate_data' do
    context 'when is call by the class instance ' do
      let(:array) { [["CALIFORNIA"], ["Rating:CARA01 *"], ["Plan ID:14033847Plan Name:CA Silver"], ["Age"]] }

      it 'should respond to formatted_age_rate_data with 1 argument' do
        expect(@pdf_to_csv).to respond_to(:formatted_age_rate_data).with(1).argument
      end
      it 'should return a hash' do
        expect(@pdf_to_csv.formatted_age_rate_data(array)).to be_instance_of(Hash)
      end
    end
  end

  describe PDFToCSV, '#build_final_data_arr ' do
    context 'when is call by the class instance ' do
      let(:symbol_hash) { @pdf_to_csv.my_data.select { |key, value| value if key.is_a?(Symbol) } }
      let(:age_rate_hash) { { "0-20"=>"421.26", "35"=>"810.67", "50"=>"1184.82" } }
      let(:final_data_arr) { @pdf_to_csv.my_data = age_rate_hash.merge(@pdf_to_csv.my_data) }

      it 'should select values from @my_data which keys are symbols ' do
        expect(final_data_arr.length).to be > 0
      end
      it 'should return an Array with concatenated values from @my_data array' do
        expect(@pdf_to_csv.build_final_data_arr).to be_instance_of(Array)
      end
    end
  end

  describe PDFToCSV, '#export_data_arr_to_csv ' do
    HEADERS_COLUMNS = ['age', 'price', 'region', 'plan_id', 'issuer_name', 'plan_name']
    before do
      @data_arr = [["0-20", "421.26", 1, 14033847, "CA Silver Indemnity 1500 80", "Aetna"],
                   ["35", "810.67", 1, 14033847, "CA Silver Indemnity 1500 80", "Aetna"],
                   ["50", "1184.82", 1, 14033847, "CA Silver Indemnity 1500 80", "Aetna"],
                   ["44", "926.76", 1, 14033847, "CA Silver Indemnity 1500 80", "Aetna"],
                  ]
      @s = CSV.generate do |csv|
        csv << HEADERS_COLUMNS
        @data_arr.each{ |row| csv << row }
      end
    end
    context 'when is call by the class instance ' do
      let(:file_name) { './data/formatted_data.csv' }
      let(:file) { File.open('./data/tabula-aeta_sample_p1.csv')}
      it 'should receive only one argument ' do
        expect(@pdf_to_csv).to respond_to(:export_data_arr_to_csv).with(1).argument
      end
      it 'should generate a csv' do
        expect(@s).to be_instance_of(String)
      end
      it 'should open a File to write the csv' do
          allow(File).to receive(:write).with(file_name)
      end
      it 'should close the @@file connection' do
          expect(file).to respond_to(:close)
      end
    end
  end
end
