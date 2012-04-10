class RylyzBloggerPlan
  include Mongoid::Document
  include Mongoid::Timestamps

  field :description, :type => String, :default => nil

  belongs_to :blogger, :class_name => "RylyzBlogger", :inverse_of => :plan
end
