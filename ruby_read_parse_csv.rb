require 'csv'
arr_info = []     # info of the 4 firsts lines of the file.
arr_age_rate = [] # info of all the Ages and Rates
my_data = Hash.new
file = File.open('./tabula-aeta_sample_p1.csv')

i = 0
while (line = file.gets)
  # validates when it is the fouth line.
  i < 4 ? arr_info << line : arr_age_rate << line
  # controls when the age_rate begins on the file.
  i += 1
end
def format_array(unformated_array)
  # 1) maps each string line of the array_info.
  # 2) Each section gets splitted by ',' into an array.
  # 3) Pops out last element which is '/\r\n/'.
  # 4) Filter elements by ''.
  formated_array = unformated_array.map do |section|
    arr = section.split(',')
    arr.pop
    arr.select do |ele|
      ele != ''
    end
  end
  formated_array
end
formatted_info = format_array(arr_info)


# Rate data is formated and on the final hash.
my_data[:rate] = formatted_info[1][0][/\d+/].to_i
# Plan_id data is formated and on the final hash.
my_data[:plan_id] = formatted_info[2][0][/\d+/].to_i
# Plan_name data is formated and on the final data hash
my_data[:plan_name] = formatted_info[2][0].scan(/\w+/)[4...formatted_info[2][0].scan(/\w+/).length-2].join(' ')

formatted_age_rate = format_array(arr_age_rate)
# 1) flatten the array to ungroup them from columns of 6.
# 2) group them in tuples by consecutives.
# 3) Turn everything into a new hash.
# 4) Merge the two hash together to have the final data hash.
age_rate_hash = formatted_age_rate.flatten.each_slice(2).to_h

puts my_data = age_rate_hash.merge(my_data)

 file.close
