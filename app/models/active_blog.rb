class ActiveBlog
  include Mongoid::Document
  include Mongoid::Timestamps

  field :blog_idx, :type => Integer, :default => 0
end