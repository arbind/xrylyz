class RylyzBloggerPlan
  include Mongoid::Document
  include Mongoid::Timestamps

  DEFAULT_PLAN_NAME = 'default'

  field :name, :type => String, :default => DEFAULT_PLAN_NAME
  field :description, :type => String, :default => nil

  field :base_profit_sharing_rate, :type => Float, :default => 0
  field :referral_rate, :type => Float, :default => 0
  field :affiliate_rate, :type => Float, :default => 0
  field :monthly_subscription_rate, :type => Float, :default => 0

  has_many :bloggers, :class_name => "RylyzBlogger", :inverse_of => :plan

  validates_uniqueness_of :name

end
