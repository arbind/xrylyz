class RylyzBloggerPlan
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, :type => String, :default => 'Free'
  field :description, :type => String, :default => nil

  field :base_profit_sharing_rate, :type => Float, :default => 0
  field :referral_rate, :type => Float, :default => 0
  field :affiliate_rate, :type => Float, :default => 0
  field :monthly_subscription_rate, :type => Float, :default => 0

  has_many :bloggers, :class_name => "RylyzBlogger", :inverse_of => :plan

  validates_uniqueness_of :name

end
