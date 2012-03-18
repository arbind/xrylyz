class ChatRoom
  include Mongoid::Document
  include Mongoid::Timestamps
  field :name, :type => String, :default=>nil
  field :_channel_id, :type => String, :default=>nil
  field :users, :type => Array, :default=>nil

  def channel_id ()
  	_channel_id ||= PusherChannels.instance.channel_name_for_class_id(self.class, _id)
  end

  def num_users
  	users.try(:count) || 0
  end

  def for_display
  	{
  		id: _id,
  		name: name,
  		num_users: num_users
  	}
  end
end
