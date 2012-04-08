class RylyzSocialPresence
  include Mongoid::Document
  include Mongoid::Timestamps

  referenced_in :rylyz_member
  field :rylyz_member_id, :type => Integer

  #oauth identification
  field :provider, :type => String
  field :uid, :type => String

  #profile info
  field :nickname, :type => String, :default=>nil
  field :email, :type => String, :default=>nil
  field :sign_in_count, :type => Integer, :default=>1
  field :last_signed_in_at, :type => DateTime, :default => DateTime.now
  field :verified?, :type => Boolean, :default => false
  field :first_name, :type => String, :default=>nil
  field :last_name, :type => String, :default=>nil
	field :timezone, :type => String, :default=>nil
	field :locale, :type => String, :default=>nil

	field :profile, :type => String, :default=>nil
	field :connections, :type => String, :default=>nil
	field :interests, :type => String, :default=>nil

	def self.materialize_from_omniauth(omniauth)
		presence = RylyzSocialPresense.new
		provider = 
		uid = 
		case provider

		return presence
	end

  def populate_omniath(omniauth)
    self.email = omniauth['user_info']['email'] if email.blank?
    # Check if email is already into the database => user exists
    apply_trusted_services(omniauth, confirmation) if self.new_record?
  end
  
  # Create a new user
  def apply_trusted_services(omniauth, confirmation)  
    # Merge user_info && extra.user_info
    user_info = omniauth['user_info']
    if omniauth['extra'] && omniauth['extra']['user_hash']
      user_info.merge!(omniauth['extra']['user_hash'])
    end  
    # try name or nickname
    if self.name.blank?
      self.name   = user_info['name']   unless user_info['name'].blank?
      self.name ||= user_info['nickname'] unless user_info['nickname'].blank?
      self.name ||= (user_info['first_name']+" "+user_info['last_name']) unless
        user_info['first_name'].blank? || user_info['last_name'].blank?
    end   
    if self.email.blank?
      self.email = user_info['email'] unless user_info['email'].blank?
    end 
  end

end