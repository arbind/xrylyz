class StripeCreditCard # mirrors a Stripe::Customer - each card has 1 Stripe::Customer id
  include Mongoid::Document
  include Mongoid::Timestamps

  field :stripe_id, :type => String, :default=>nil
  field :stripe_token, :type => String, :default=>nil
  field :last_4_digits, :type => String, :default=>nil
  validates_presence_of :last_4_digits

  belongs_to :member, :class_name => "RylyzMember", :inverse_of => :credit_cards

  before_save :update_stripe


  # ref: http://railscasts.com/episodes/288-billing-with-stripe
  # ref: https://github.com/GoodCloud/django-zebra
  # ref: https://github.com/collision/monospace-rails/blob/master/app/models/user.rb
  def update_stripe
    if stripe_token.present?
      if stripe_id.nil?
        customer = Stripe::Customer.create(
          :description => email,
          :card => stripe_token
        )
        self.last_4_digits = customer.active_card.last4
        response = customer.update_subscription({:plan => "premium"})
      else
        customer = Stripe::Customer.retrieve(stripe_id)
        customer.card = stripe_token
        customer.save
        self.last_4_digits = customer.active_card.last4
      end

      self.stripe_id = customer.id
      self.stripe_token = nil
    elsif last_4_digits_changed?
      self.last_4_digits = last_4_digits_was
    end
  end
