

require 'json'
require 'spreadsheet'

string = '{
 "2021-04-01": {
   "JTG1": {
     "in": "09:00",
     "out": "18:00"
   },
   "JTG2": {
     "in": "10:00",
     "out": "10:30"
   }
 },
 "2021-04-02": {
   "JTG1": {
     "in": "09:30",
     "out": "18:10"
   },
   "JTG2": {
     "in": "10:15",
     "out": "10:55"
   }
 }
}'

def function(string)

  [REVIEW] <handle case when string is not in proper JSON to avoid 500>
  parsed = JSON.parse(string)
  number_of_days = 0
  [REVIEW] <use default hash value>
  employee_average_working_hours =  Hash.new { |hash, key| hash[key] = 0 }
  employee_vacations = Hash.new {|hash, key| hash[key] = 0}
  employee_half_days = Hash.new {|hash, key| hash[key] = 0 }
  employee_average_in_time = Hash.new { |hash, key| hash[key] = 0 }
  employee_average_out_time = Hash.new { |hash, key| hash[key] = 0 }

  [REVIEW] <Process each candidate only once to avoid unneccesary loop>


  parsed.each do |date, employee|
    number_of_days += 1

    [REVIEW] <Try using pluck with max out time and min in time to avoid inner loop>


    employee.each do |name, timing|
      in_time = timing['in'].to_f +  timing['in'].slice(3,4).to_f/60
      out_time = timing['out'].to_f+ timing['out'].slice(3,4).to_f/60

      work_hours = out_time - in_time

      employee_average_working_hours[name]+= work_hours

      if work_hours < 2
        employee_vacations[name]+= 1
      end

      if  work_hours > 2 && work_hours < 6
        employee_half_days[name] += 1
      end

      employee_average_in_time[name] += in_time
      employee_average_out_time[name] += out_time
    end
  end

  [REVIEW] <Process each candidate only once to avoid unneccesary loop, this loop can be avoided>
  employee_average_in_time.each do|name, time|
    time =  employee_average_in_time[name]/number_of_days
    hour = time.to_i
    minutes =  (time - hour)*60
    employee_average_in_time[name]=[hour,minutes].join(":")
  end

  [REVIEW] <Process each candidate only once to avoid unneccesary loop>

  employee_average_out_time.each do|name, time|
    time =  employee_average_out_time[name]/number_of_days
    hour = time.to_i
    minutes =  (time - hour)*60
    employee_average_out_time[name]=[hour,minutes].join(":")
  end

  employee_average_working_hours.each do|name, time|
    employee_average_working_hours[name] = employee_average_working_hours[name]/number_of_days
  end

  record = Spreadsheet::Workbook.new
  sheet = record.create_worksheet
  sheet.row(0).concat %w{Name WorkHours Vacations HalfDays InTime OutTime}

  [REVIEW] <Why i .push will do same>
  i=1
  employee_average_working_hours.each do|name, time|
    sheet.row(i).push name, time, employee_vacations[name], employee_half_days[name], employee_average_in_time[name], employee_average_out_time[name]
    i +=1
  end

  record.write '/home/ubuntu1821/record1.xls'
end


function(string)



