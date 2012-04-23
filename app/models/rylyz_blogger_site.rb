class RylyzBloggerSite
  include Mongoid::Document
  include Mongoid::Timestamps

  validates_uniqueness_of :url

  # Site details
  field :url,         :type => String, :default => nil
  field :title,       :type => String, :default => nil
  field :description, :type => String, :default => nil

  # Site status
  field :status,          :type => String, :default => "invalid_url"
  field :active_status,   :type => String, :default => "inactive"
  field :approval_status, :type => String, :default => nil

  belongs_to :blogger, :class_name => "RylyzBlogger", :inverse_of => :sites
end

# Lets add 3 status variables:

# Site status
# valid_url: url exists
# invalid_url: url does not exist
# wyjyt_verified: widget exists on site

# Site Active Status
# active: site is generating visits
# inactive: no visitors are comming from this site

# Site approval status
# unqualified: site does not fit our polciy qualifications
# approved: site is of quality and ok to use
