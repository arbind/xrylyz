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

  def self.uri_components(url)
    return nil if url.blank?

    s = nil
    d = nil

    uri = URI.parse(url)
    uri = URI.parse("http://#{url}") unless uri.scheme
    if uri.scheme
      s = uri.scheme.downcase
      d = uri.host.downcase
    end
    return nil if d.blank?
    return nil unless ["http", "https"].include?(s)
    return nil unless hostname_resolves?(d)
    [s, d]
  end

  def scrape_attributes
    page = MetaInspector.new(url)
    return false unless page
      self.title = page.title rescue nil
      self.description = page.description rescue nil
  end

  require 'resolv'

  def self.hostname_resolves?(hostname)
    return nil if hostname.blank?
    begin
      Resolv.getaddress(hostname)
    rescue Resolv::ResolvError => e
      puts "#{e.message}"
      nil
    end
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
