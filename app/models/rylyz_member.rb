  # +++ consider adding devise:
  #  https://github.com/plataformatec/devise
  #
  # References for this Class:
  # https://github.com/fertapric/rails3-mongoid-devise-omniauth/blob/master/app/models/user.rb

class RylyzMember
  include Mongoid::Document
  include Mongoid::Timestamps
  field :nickname, :type => String, :default=>nil
  field :email, :type => String, :default=>nil
  field :sign_in_count, :type => Integer, :default=>0
  field :last_signed_in_at, :type => DateTime, :default => ->{ DateTime.now }
  field :is_verified, :type => Boolean, :default => false
  field :is_active, :type => Boolean, :default => true

  has_many :rylyz_member_presences, :dependent => :destroy
  has_many :credit_cards, :dependent => :destroy

  belongs_to :blogger, :class_name => "RylyzBlogger", :inverse_of => :member
  belongs_to :super_user, :class_name => "RylyzSuperUser", :inverse_of => :member

  validates_presence_of :nickname
  # validates_uniqueness_of :email, :case_sensitive => false

  alias :social_presences :rylyz_member_presences

  def self.materialize(email, nickname, is_verified=false)
    member = RylyzMember.where(:email => email).first
    if member
      # no need to override nickname
      member.verify(member.is_verified || is_verified)
    else
      member = RylyzMember.new
      member.email = email
      member.nickname = nickname
      member.verify(is_verified)
    end

    if member.save then member else nil end
  end

  def add_social_presence(social_presence)
    p = social_presences.where(:provider => social_presence.provider, :uid => social_presence.uid).first
    if p.nil?
      social_presences << social_presence
    end
  end

  def mark_sign_in
    # +++
    # self.update({sign_in_count, last_signed_in_at})
  end

  def verify(is_verified=true) self.is_verified = is_verified end
  def inactivate() self.is_active = false end
  def reactivate() self.is_active = true end

  def save_stripe_credit_card(stripe_token, stripe_plan_id=nil)
    customer = Stripe::Customer.create(
      :card => stripe_token,
      :plan => stripe_plan_id,
      :email => email,
      :description => "[#{id.to_s}] #{nickname} (#{email})"
    )
    if not customer.nil? and not customer.active_card.nil?
      card_info = {
        :stripe_customer_id=> customer.id,
        :stripe_card_fingerprint => customer.active_card.fingerprint,
        :stripe_card_type => customer.active_card.type,
        :stripe_card_last4 => customer.active_card.last4,
        :stripe_card_holder_name => customer.active_card.name,
        :stripe_card_expiration_month => customer.active_card.exp_month,
        :stripe_card_expiration_year => customer.active_card.exp_year
      }
      credit_cards.create!(card_info)
    end
  end

end
