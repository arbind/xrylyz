class RylyzBloggerSite
  include Mongoid::Document
  include Mongoid::Timestamps

  # Site details
  field :scheme,      :type => String, :default => 'http'
  field :domain,      :type => String, :default => nil
  field :title,       :type => String, :default => nil
  field :description, :type => String, :default => nil
  field :site_key,    :type => String, :default => nil

  # Site status
  field :status,          :type => String, :default => "invalid_url"
  field :active_status,   :type => String, :default => "inactive"
  field :approval_status, :type => String, :default => nil

  belongs_to :blogger, :class_name => "RylyzBlogger", :inverse_of => :sites

  before_create :scrape_attributes
  before_save :check_site_key

  def url() "#{scheme}://#{domain}" end

  private

  def scrape_attributes
    uri = URI.parse(domain)
    if uri.scheme
      self.domain = uri.host
      self.scheme = uri.scheme
    end
    return false if domain.blank?

    page = MetaInspector.new(self.domain)
    return false unless page

    self.title = page.title
    self.description = page.description
  end

  def check_site_key
    self.site_key ||= generate_site_key
  end

  def generate_site_key
    key = UIDService.generate_key(self.domain)
    self.site_key = key
  end
end

# Lets add 3 status variables:

# Site status
# valid_url: url exists
# invalid_url: url does not exist
# wygyt_verified: widget exists on site

# Site Active Status
# active: site is generating visits
# inactive: no visitors are comming from this site

# Site approval status
# unqualified: site does not fit our polciy qualifications
# approved: site is of quality and ok to use
