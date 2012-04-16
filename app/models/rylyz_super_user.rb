class RylyzSuperUser
  include Mongoid::Document
  include Mongoid::Timestamps

  has_one :member, :class_name => "RylyzMember", :inverse_of => :super_user
end
