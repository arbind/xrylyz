class RylyzBlogger
  include Mongoid::Document
  include Mongoid::Timestamps

  field :email, :type => String, :default => nil
  field :invite_code, :type => String, :default => nil

  has_one :member, :class_name => "RylyzMember", :inverse_of => :blogger
  has_one :plan, :class_name => "RylyzBloggerPlan", :inverse_of => :blogger
  has_many :sites, :class_name => "RylyzBloggerSite", :inverse_of => :blogger
end
