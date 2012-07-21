class RylyzBlogger
  include Mongoid::Document
  include Mongoid::Timestamps


  # identification
  field :email, :type => String, :default => nil
  field :share_key, :type => String, :default => nil

  # personal info
  field :first_name, :type => String, :default=>nil
  field :last_name, :type => String, :default=>nil
  field :phone, :type => String, :default=>nil

  # customer relationship info
  field :is_early_adopter, :type => Boolean, :default => false
  field :is_alpha_tester, :type => Boolean, :default => false

  # referral stats
	field :referred_by, :type => String, :default => nil
	field :share_clicks, :type => Integer, :default => 0
	field :share_conversions, :type => Integer, :default => 0

  # signup history
	field :signedup_at, :type => DateTime, :default => nil
  field :activated_at, :type => DateTime, :default => nil

  # communication prefs
  field :do_not_email, :type => Boolean, :default => false

  # session history
  field :login_count, :type => Integer, :default => 0

  has_one :member, :class_name => "RylyzMember", :inverse_of => :blogger
  has_many :sites, :class_name => "RylyzBloggerSite", :inverse_of => :blogger
  belongs_to :plan, :class_name => "RylyzBloggerPlan", :inverse_of => :bloggers

  validates_uniqueness_of :email
  validates_uniqueness_of :share_key

  after_initialize :check_plan_exists


  def nickname 
  	nick = self.email.split('@').first if self.email
  	nick ||= self.member.nickname if self.member
  	nick ||= 'blogger'
  end

  private

  def check_plan_exists
    return true unless plan.nil?
    self.plan = RylyzBloggerPlan.find_or_create_by(name:  RylyzBloggerPlan::DEFAULT_PLAN_NAME)
    self.save
  end
end
