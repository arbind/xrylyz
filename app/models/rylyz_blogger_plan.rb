class RylyzBloggerPlan
  include Mongoid::Document
  include Mongoid::Timestamps

  field :description, :type => String, :default => nil
  field :profit_sharing_rate, :type => Float, :default => 0
  field :referral_rate, :type => Float, :default => 0
  field :monthly_subscription_rate, :type => Float, :default => 0

  belongs_to :blogger, :class_name => "RylyzBlogger", :inverse_of => :plan

end
