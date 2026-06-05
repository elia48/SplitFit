module ApplicationHelper
  FALLBACK_TRAINING_IMAGE = "https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=600"

  def training_image(training)
    if training.photo.present?
      asset_path(training.photo)
    elsif training.user&.avatar.present?
      asset_path(training.user.avatar)
    else
      FALLBACK_TRAINING_IMAGE
    end
  end

  def format_price(cents)
    sprintf("%.2f", cents / 100.0)
  end
end
