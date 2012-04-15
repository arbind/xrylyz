# +++ turn this into a module
class PaymentGateway::StripeController < ApplicationController
  include ApplicationHelper
  require 'stripe'

  # ref: http://railscasts.com/episodes/288-billing-with-stripe
  def authorize_charge
		# set your secret key: remember to change this to your live secret key in production
		# see your keys here https://manage.stripe.com/account
		Stripe.api_key = SECRETS[:STRIPE][:SECRET]

		# get the credit card details submitted by the form
		token = params[:stripeToken]

		# create the charge on Stripe's servers - this will charge the user's card
		charge = Stripe::Charge.create(
		  :amount => 1000, # amount in cents, again
		  :currency => "usd",
		  :card => token,
		  :description => "payinguser@example.com"
		)
  end


  def authorize_subscription
	end
end
