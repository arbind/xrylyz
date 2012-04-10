class RylyzBloggerSite
  include Mongoid::Document
  include Mongoid::Timestamps

  field :url, :type => String, :default => nil

  belongs_to :blogger, :class_name => "RylyzBlogger", :inverse_of => :sites
end
