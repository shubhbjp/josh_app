Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  get '/employee-list-in-room/:room_id', to: 'assignment#get_emp_list_in_room'
  get '/employee-update-room', to: 'assignment#show_update'
  put 'employee-update-room', to: 'assignment#update_emp_room_no'
end
