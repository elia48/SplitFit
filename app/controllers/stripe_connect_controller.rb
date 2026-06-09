class StripeConnectController < ApplicationController
  skip_after_action :verify_authorized
  skip_after_action :verify_policy_scoped

  def onboard
    if current_user.stripe_account_id.present?
      account_id = current_user.stripe_account_id
    else
      account = Stripe::Account.create(type: "express", email: current_user.email)
      current_user.update!(stripe_account_id: account.id)
      account_id = account.id
    end

    link = Stripe::AccountLink.create(
      account: account_id,
      refresh_url: stripe_connect_refresh_url,
      return_url: stripe_connect_return_url,
      type: "account_onboarding"
    )

    redirect_to link.url, allow_other_host: true
  rescue Stripe::StripeError => e
    redirect_to user_path(current_user), alert: "Could not start Stripe onboarding: #{e.message}"
  end

  def return
    redirect_to user_path(current_user), notice: "Stripe account connected! You can now receive payouts."
  end

  def refresh
    redirect_to stripe_connect_onboard_path, alert: "Your Stripe link expired. Please try again."
  end
end
