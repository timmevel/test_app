class Booking < ActiveRecord::Base
  belongs_to :show
  #before_save :check_capacity
  #after_save :update_capacity



  #def update_capacity
  #  show.capacity = show.capacity - number
  #  show.save
  #end
end
