class RylyzBloggerSite
  include Mongoid::Document
  include Mongoid::Timestamps

  # Site details
  field :scheme,      :type => String, :default => 'http'
  field :domain,      :type => String, :default => nil
  field :title,       :type => String, :default => nil
  field :description, :type => String, :default => nil

  # Site status
  field :status,          :type => String, :default => "invalid_url"
  field :active_status,   :type => String, :default => "inactive"
  field :approval_status, :type => String, :default => nil

  belongs_to :blogger, :class_name => "RylyzBlogger", :inverse_of => :sites

  before_create :scrap_attributes

  def url
    "#{scheme}://#{domain}"
  end

  private

  def scrap_attributes
    page = MetaInspector.new(self.domain)
    self.title = page.title
    self.description = page.description
  end
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
