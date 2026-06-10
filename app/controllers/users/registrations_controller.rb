class Users::RegistrationsController < Devise::RegistrationsController
  protected

  def after_sign_up_path_for(resource)
    resource.is_coach? ? coach_welcome_path : search_path
  end
end
