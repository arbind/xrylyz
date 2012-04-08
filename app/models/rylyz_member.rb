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
  field :sign_in_count, :type => Integer, :default=>1
  field :last_signed_in_at, :type => DateTime, :default => DateTime.now
  field :isVerified, :type => Boolean, :default => false
  field :isActive, :type => Boolean, :default => true
  references_many :rylyz_social_presences, :dependent => :delete

  validates_presence_of :nickname
  # validates_uniqueness_of :email, :case_sensitive => false    

  def self.materialize(nickname, email, isVerified=false)
    member = RylyzMember.new
    member.email = email
    member.nickname = nickname
    member.verify(isVerified)
    member
  end

  def verify(isVerified=true)
    self.isVerified = isVerified
  end

end