module ApplicationHelper
  def training_image(training)
    if training.photo.attached?
      url_for(training.photo)
    elsif training.user&.avatar&.attached?
      url_for(training.user.avatar)
    end
  end

  # Returns a Cloudinary-transformed image URL suitable for og:image (1200x630).
  # Falls back to the plain image URL when not on Cloudinary (e.g. local dev).
  def training_og_image_url(training)
    base = training_image(training)
    return base unless base&.include?("res.cloudinary.com")

    enc = ->(s) { CGI.escape(s.to_s.gsub("€", "EUR")).gsub("+", "%20") }

    type_text  = enc.(training.workout_type.upcase)
    coach_text = enc.("with #{training.user&.name || 'Coach'}")
    date_text  = enc.(training.date.strftime("%-d %b %Y  |  %H:%M"))
    price_text = enc.("From EUR #{format_price(training.min_price_cents)} / person")

    transforms = [
      "c_fill,w_1200,h_630,g_auto,q_auto,f_jpg",
      "e_gradient_fade:90,y_-0.4,co_black",
      "l_text:Arial_bold_70:#{type_text},co_white,g_south_west,x_60,y_190",
      "l_text:Arial_36:#{coach_text},co_white,g_south_west,x_62,y_145,o_90",
      "l_text:Arial_28:#{date_text},co_white,g_south_west,x_62,y_100,o_80",
      "l_text:Arial_bold_36:#{price_text},co_rgb:FF6428,g_south_west,x_62,y_50"
    ]

    base.sub("/upload/", "/upload/#{transforms.join('/')}/")
  end

  def format_price(cents)
    sprintf("%.2f", cents / 100.0)
  end
end
