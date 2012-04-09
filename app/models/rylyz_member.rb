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
  field :last_signed_in_at, :type => DateTime, :default => DateTime.now
  field :is_verified, :type => Boolean, :default => false
  field :is_active, :type => Boolean, :default => true
  has_many :rylyz_member_presences, :dependent => :delete

  validates_presence_of :nickname
  # validates_uniqueness_of :email, :case_sensitive => false    

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

  def social_presences
    self.rylyz_member_presences
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

  def verify(is_verified=true)
    self.is_verified = is_verified
  end

  def inactivate()
    self.is_active = false
  end

  def reactivate()
    self.is_active = true
  end

end
