class AssignmentController < ApplicationController

	def get_emp_list_in_room
		begin
			room_id = params[:room_id].to_i rescue 0
			raise "Invalid Room Id Passed" if room_id  == 0
			emp_list = Employee.get_emp_list_in_alloted_room(room_id)
			raise "No Employee Found" if emp_list.blank?
			response = {success: true, data: emp_list, message: "Employee List Founded Successfully"}
		rescue Exception => e
			Rails.logger.info "Exception | #{e.message} | #{params}"
			response = {success:false, data:[], message: "#{e.message}"}
		end
		render json: response
	end

	def show_update
		@emp_id = params[:emp_id].to_i rescue 0
		@room_no = params[:room_no].to_i rescue 0
		@message = params[:message] rescue ""
	end

	def update_emp_room_no
		begin
			emp_id = params[:emp_id].to_i rescue 0
			room_no = params[:room_no].to_i rescue 0
			raise "No Employee Exists" if emp_id == 0
			raise "No Room Exists" if room_no == 0
			success, message = Employee.update_room_no_of_emp(emp_id, room_no)
			response = {success:success, message: message}
			redirect_to employee_update_room_path(room_no: room_no, emp_id: emp_id, message: message)
		rescue Exception => e
			Rails.logger.info "Exception | #{e.message} | #{params}"
			response = {success:false, message: "#{e.message}"}
		end
	end
end