module ApplicationHelper
  def training_image(training)
    if training.photo.attached?
      url_for(training.photo)
    elsif training.user&.avatar&.attached?
      url_for(training.user.avatar)
    end
  end

  def format_price(cents)
    sprintf("%.2f", cents / 100.0)
  end
end
