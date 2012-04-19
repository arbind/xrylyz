class CreditCard
  include Mongoid::Document
  include Mongoid::Timestamps

  #Stripe Customer
  field :stripe_customer_id, :type => String, :default=>nil

  #Stripe CreditCard
  field :stripe_card_id, :type => String, :default=>nil
  field :stripe_card_fingerprint, :type => String, :default=>nil
  field :stripe_card_type, :type => String, :default=>nil
  field :stripe_card_last4, :type => String, :default=>nil
  field :stripe_card_holder_name, :type => String, :default=>nil
  field :stripe_card_expiration_month, :type => Integer, :default=>nil
  field :stripe_card_expiration_year, :type => Integer, :default=>nil

  #Stripe Plan
  field :stripe_plan_id, :type => String, :default=>nil

  validates_presence_of :last_4_digits, :stripe_customer_id, :stripe_card_fingerprint

  belongs_to :member


  # +++ on before create callback, verify that this fingerprint is not already being used by another member - or at lest notify the original member
  # +++ on before destroy callback, remove the stripe customer from stripe

  #charge
  def charge(cents, currency="usd")
		Stripe::Charge.create(
	    :amount => cents,
	    :currency => currency,
	    :customer => stripe_customer_id
		)
  end

  def charges() stripe_customer.charges end
  def refund(charge_id)
  	charge = Stripe::Charge.retrieve(charge_id)
  	charge.refund() if charge
  end 

  # subscription
  def subscribe_to_plan(plan_id) stripe_customer.update_subscription({:plan => plan_id}) end
  def cancel_subscription() stripe_customer.cancel_subscription() end

  #invoice
  def invoices() stripe_customer.invoices end
  def invoice_items() stripe_customer.invoice_items end
  def add_invoice_item(params) stripe_customer.add_invoice_item(params) end

private:
  def stripe_customer
  	@customer ||= Stripe::Customer.retrieve(stripe_customer_id)
  end


end
