class Room < ApplicationRecord
  has_many :seats, dependent: :destroy
  has_many :emp_date_wise_seat, through: :seats
end
