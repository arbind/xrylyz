class RylyzBlogger
  include Mongoid::Document
  include Mongoid::Timestamps

  field :email, :type => String, :default => nil
  field :invite_code, :type => String, :default => nil

  field :is_alpha_tester, :type => Boolean, :default => false
	field :hi_email_sent, :type => Boolean, :default => false
	field :referred_by, :type => String, :default => nil
	field :share_url, :type => String, :default => nil
	field :share_clicks, :type => Integer, :default => 0
	field :share_conversions, :type => Integer, :default => 0
	field :signup_ip, :type => String, :default => nil
	field :signup_at, :type => DateTime, :default => DateTime.now

  has_one :member, :class_name => "RylyzMember", :inverse_of => :blogger
  has_one :plan, :class_name => "RylyzBloggerPlan", :inverse_of => :blogger
  has_many :sites, :class_name => "RylyzBloggerSite", :inverse_of => :blogger

  def nickname 
  	nick = self.email.split('@').first if self.email
  	nick ||= self.member.nickname if self.member
  	nick ||= 'blogger'
  end
end
