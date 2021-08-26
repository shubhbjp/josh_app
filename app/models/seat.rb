class Seat < ApplicationRecord
  belongs_to :room
  has_one :employee
  has_many :emp_date_wise_seat, :foreign_key => "seat_id"

  scope :get_all_seats_in_room, ->(room_id) { self.where(room_id: room_id).pluck(:id) rescue []}
  scope :get_room_wise_seat_count, -> () {self.group(:room_id).count}

  def self.room_with_more_than_n_emp(n=0)
    count_of_rooms = self.get_room_wise_seat_count
    return [] if count_of_rooms.blank?
    count_of_employee_in_each_room = []
    count_of_rooms.keys.each do |c|
      available_seats = self.get_all_seats_in_room(c) if count_of_rooms[c] >= n
      next if available_seats.blank?
      emp_count = Employee.where("curr_seat_id = ? ", available_seats).count
      count_of_employee_in_each_room << {room_id: c, emp_count: emp_count} if emp_count >=n
    end
    return count_of_employee_in_each_room
  end

  def self.get_emp_seat_on_given_date(emp_id=0, date='')
    response = {room_id: '', seat_id: ''}
    date = date.to_date.strftime("%Y-%m-%d") rescue Date.today.strftime("%Y-%m-%d")
    data = self.joins(:emp_date_wise_seat).where("emp_date_wise_seats.employee_id = ?", emp_id).where("DATE(emp_date_wise_seats.created_at) <= ?", date).order("emp_date_wise_seats.id desc").try(:first) rescue ''
    response[:room_id] = data.room_id rescue ''
    response[:seat_id] = data.id rescue ''
    return response
  end
end
