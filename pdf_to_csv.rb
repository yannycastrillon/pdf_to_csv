require 'csv'

class PDFToCSV
  attr_accessor :my_data, :arr_headers_line_csv, :arr_age_rate_line_csv
  HEADERS_COLUMNS = [ 'age', 'price', 'region', 'plan_id', 'issuer_name', 'plan_name']

  def initialize(file_name)
    @@file = File.open(file_name)
    @arr_headers_line_csv = []
    @arr_age_rate_line_csv = []
    @my_data = Hash.new

    i = 0
    while (line = @@file.gets)
      # validates when it is the fouth line to separate headers from age_rates.
      i < 4 ? @arr_headers_line_csv << line : @arr_age_rate_line_csv << line
      # controls when the numbers "age_rate" begins on the file.
      i += 1
    end
  end

  # 1) maps each string line of the array_info.
  # 2) Each section gets splitted by ',' into an array.
  # 3) Pops out last element which is '/\r\n/'.
  # 4) Filter elements by ''.
  def format_array(unformated_array)
    begin
      unformated_array.map do |section|
        arr = section.split(',')
        arr.pop
        arr.select do |ele|
          ele != ''
        end
      end
    rescue Exception => e
      raise "Invalid Format"
    end
  end

  # Assigns static data to instance variable "@my_data" hash
  def add_description_data(hash)
    hash.keys.each {|key| @my_data[key] = hash[key]}

    # puts "----------- AFTER DESCRIPTION  -----------"
    # puts @my_data
    # puts "----------------------"
  end

  # Class method in charge of retrieving the portion of data from each headers array-string.
  def self.retrieve_value_with_regexp(formated_headers)
    hash = Hash.new
    # "Rate" Regexp to extract rate.
    hash[:rate] = formated_headers[1][0][/\d+/].to_i
    # "Plan_id" Regexp to extract plan id.
    hash[:plan_id] = formated_headers[2][0][/\d+/].to_i
    # "Plan_name" Regexp to extract plan name.
    hash[:plan_name] = formated_headers[2][0].scan(/\w+/)[4...formated_headers[2][0].scan(/\w+/).length-2].join(' ')
    hash[:issuer_name] = "Aetna"
    # puts "----------- REGEX VALUES -----------"
    # puts hash
    # puts "----------------------"

    hash
  end

  # 1) flatten the array to ungroup them from columns of 6.
  # 2) group them in consecutives tuples.
  # 3) Turn everything into a new hash.
  # 4) Merge the two hash together to have the final data hash.
  def formatted_age_rate_data(array)
    array.flatten.each_slice(2).to_h
  end


  # Constructs and prepares array to be able to export to .csv file
  def build_final_data_arr
    symbol_hash = @my_data.select { |key, value| value if key.is_a?(Symbol) }
    final_data_arr = @my_data.to_a.map { |row_array| row_array +  symbol_hash.values }
    final_data_arr.slice(0..final_data_arr.length - 5)
  end

  # Export "final_data_arr" array into formatted .csv file.
  def export_data_arr_to_csv(data_arr)
    s = CSV.generate do |csv|
      csv << HEADERS_COLUMNS
      data_arr.each{ |row| csv << row }
    end
    File.write('formatted_data.csv', s)
    @@file.close
  end
end

# Object of the class PDFToCSV and initializer
# - "arr_headers_line_csv" and "arr_age_rate_line_csv"
obj = PDFToCSV.new("./tabula-aeta_sample_p1.csv")

arr_headers_line_csv = obj.arr_headers_line_csv
formated_headers = obj.format_array(arr_headers_line_csv)

# puts "---------------formated_headers--------------"
# p formated_headers
# puts "-----------------------------"

obj.add_description_data(PDFToCSV.retrieve_value_with_regexp(formated_headers));

arr_age_rate_line_csv = obj.arr_age_rate_line_csv

formatted_age_rate = obj.format_array(arr_age_rate_line_csv)
# puts "--------------- formatted_age_rate--------------"
# p formatted_age_rate
# puts "-----------------------------"
#
age_rate_hash = obj.formatted_age_rate_data(formatted_age_rate)

# puts "--------------- age_rate_hash --------------"
# p age_rate_hash
# puts "-----------------------------"
#
obj.my_data = age_rate_hash.merge(obj.my_data)

# puts "----------- final_data_arr ------------"
# p obj.build_final_data_arr
# puts "----------- final_data_arr ------------"
#
# take out
obj.export_data_arr_to_csv(obj.build_final_data_arr)
