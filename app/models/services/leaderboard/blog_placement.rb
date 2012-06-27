class BlogPlacement
  include Mongoid::Document
  include Mongoid::Timestamps

  field :blog_url, :type => String #, :default => "not nil"
  field :score,    :type => Integer, :default => -1
  field :info,     :type => Hash
end