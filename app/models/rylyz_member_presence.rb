# represents a member's social presence on a social providers site (e.g. facebook, twitter, etc)

class RylyzMemberPresence
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :rylyz_member

  #oauth identification
  field :provider, :type => String
  field :uid, :type => String
	field :credentials, :type => Hash

  #presence
  field :nickname, :type => String, :default => nil
  field :image, :type => String, :default => nil

  #profile
  field :name, :type => String, :default => nil
  field :email, :type => String, :default => nil
  field :first_name, :type => String, :default=>nil
  field :last_name, :type => String, :default=>nil
  field :gender, :type => String, :default=>nil
  field :born_on, :type => String, :default=>nil
	field :timezone, :type => String, :default=>nil
	field :locale, :type => String, :default=>nil
  field :is_verified, :type => Boolean, :default => false

  # social graph
	field :following, :type => String, :default=>nil
	field :followers, :type => String, :default=>nil
	field :connections, :type => String, :default=>nil # aka friends
	field :interests, :type => String, :default=>nil

	# rylyz activity
  field :sign_in_count, :type => Integer, :default => 1
  field :last_signed_in_at, :type => DateTime, :default => DateTime.now

	field :extra_info, :type => Hash

  def member() self.rylyz_member end
  def signed_in_before?()  !!member end
  def never_signed_in_before?() !signed_in_before? end

  def mark_sign_in
    # +++
    # self.update({sign_in_count, last_signed_in_at})
  end

	def self.materialize_from_omni_auth(omniauth)
    provider = omniauth['provider']
    uid = omniauth['uid']
    user_info = omniauth['user_info'] || {}

		# see if member already exists, else create one
    presence = RylyzMemberPresence.where(:provider => provider, :uid => uid).first || RylyzMemberPresence.new

    # update
		presence.provider = omniauth['provider']
		presence.uid = omniauth['uid']
		credentials = omniauth['credentials']

		# +++ todo: born_on and gender

		# +++ normalize credentials token, secret, expiration, etc for all providers
		presence.credentials = credentials

		info = omniauth['info']
		unless info.nil? # nickname,email,name,first_name,last_name,image, urls, etc
			info.each do |prop, value|
				p = prop
				presence[prop] = value
			end
		end

		extra = omniauth['extra']
		unless extra.nil?
			extra_info = extra['raw_info'] || extra['user_hash']
			unless extra_info.nil?
				presence.timezone = extra_info['timezone'] || extra_info['timeZone']
				# +++ normalize timezone to be utc offset for each provider
				presence.locale = extra_info['locale'] || extra_info['language'] || extra_info['lang']
				# +++ normalize locale to map to i18n for each provider
				presence.is_verified = extra_info['verified'] || extra_info['verified_email']
				# +++ normalize if email is verified for each provider if available
			end

			# call specialized handler for omni auth extra data for each provider
			method_name = "populate_from_omni_auth_extra_for_#{presence.provider.downcase}".to_sym
			presence.send(method_name, extra)  if presence.methods.include?(method_name)
		end

		#ensure name and nickname are not blank
    if presence.nickname.blank?
      presence.nickname = presence.name
      presence.nickname ||= presence.first_name + (presence.last_name || "") unless presence.first_name.nil?
      presence.nickname ||= presence.last_name
      presence.nickname ||= presence.email
      presence.nickname ||= presence.uid
    end

    if presence.name.blank?
      presence.name   = user_info['name']   unless user_info['name'].blank?
      presence.name ||= user_info['nickname'] unless user_info['nickname'].blank?
      presence.name ||= (user_info['first_name']+" "+user_info['last_name']) unless
        user_info['first_name'].blank? || user_info['last_name'].blank?
    end

		if presence.save then presence else nil end
	end

	def populate_from_omni_auth_extra_for_twitter (extra)
		#+++ normalize time_zone: locale/ language etc
		extra_info = extra['raw_info']
		unless extra_info.nil?
			utc_offset = extra_info['utc_offset']
			# +++ set to timezone
			v = extra_info['screen_name'] || extra_info['nickname']
			nickname = v unless v.nil?
		end
		self.extra_info = extra['raw_info']
	end
	def populate_from_omni_auth_extra_for_facebook (extra)
		self.extra_info = extra['raw_info']
	end
	def populate_from_omni_auth_extra_for_linkedin (extra)
		self.extra_info = extra['raw_info']
	end

	def populate_from_omni_auth_extra_for_google_oauth2 (extra)
		self.extra_info = extra['raw_info']
	end

	def populate_from_omni_auth_extra_for_meetup (extra)
		self.extra_info = extra['raw_info']
	end

	def populate_from_omni_auth_extra_for_yahoo (extra)
		self.extra_info = extra['raw_info']
	end

	def populate_from_omni_auth_extra_for_windowslive (extra)
		self.extra_info = extra['raw_info']
	end

	def populate_from_omni_auth_extra_for_tumblr (extra)
		self.extra_info = extra['user_hash']
	end

	def populate_from_omni_auth_extra_for_runkeeper (extra)
		self.extra_info = extra['raw_info']
	end

	def populate_from_omni_auth_extra_for_netflix (extra)
		self.extra_info = extra['raw_info']
	end

end