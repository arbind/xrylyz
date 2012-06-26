class PlayerPlacement
  include Mongoid::Document
  include Mongoid::Timestamps

  field :nickname, :type => String #, :default => "not nil"
  field :blog_url, :type => String #, :default => "not nil"
  field :score,    :type => Integer, :default => -1
  field :info,     :type => Hash

  has_one :member
end