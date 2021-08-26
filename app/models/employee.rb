class Employee < ApplicationRecord
  has_many :emp_date_wise_seat, :foreign_key => "employee_id"
  belongs_to :seat, :foreign_key => "curr_seat_id"
  scope :get_occupied_seat_in_room, ->(room_id) { self.joins(:seat).where("seats.room_id=?",room_id).order(:curr_seat_id) }
  
  before_save :create_emp_date_wise_seat

  def self.get_emp_list_in_alloted_room(room_id = 0)
    emp_list = self.get_occupied_seat_in_room(room_id)
    return [] if emp_list.blank?
    emp_details = []
    emp_list.each do |e|
      emp_details << {seat_id: e.curr_seat_id, name: e.name, emp_id: e.id}
    end
    return emp_details
  end

  def self.update_room_no_of_emp(emp_id, room_id)
    occupied_seats = self.get_occupied_seat_in_room(room_id)
    emp_seated_in_room = occupied_seats.pluck(:id) rescue []
    return false, "Emp #{emp_id} is already seated in Room #{room_id}" if emp_seated_in_room.include?emp_id
    occupied_seats = occupied_seats.pluck(:curr_seat_id) rescue []
    all_seats_in_room = Seat.get_all_seats_in_room(room_id)
    first_available_seat = ''
    all_seats_in_room.each do |e| 
      next if occupied_seats.include?(e) 
      first_available_seat=e 
      break
    end
    return false, "No Seats Available in Room #{room_id}" if first_available_seat.blank?
    emp_details = self.find_by_id(emp_id)
    emp_details.curr_seat_id = first_available_seat
    emp_details.save!
    return true, "Room No Updated Succeessfully"
  end

  def self.get_max_occupied_room()
    maxCount = 0
    maxCountRoom = 0
    Room.all.each do |r|
      currCount = get_emp_list_in_alloted_room(r.id).size
      if currCount > maxCount
        maxCount = currCount
        maxCountRoom = r.id
      end
    end
    return {room_id: maxCountRoom}.to_json
  end


  private

  def create_emp_date_wise_seat
    EmpDateWiseSeat.create({employee_id: self.id, seat_id: self.curr_seat_id})
  end
end
