class ChatRoom
  include Mongoid::Document
  include Mongoid::Timestamps
  field :name, :type => String, :default=>nil
  field :_channel_id, :type => String, :default=>nil
  field :visitor_ids, :type => Array, :default=>nil

  def channel_id ()
  	_channel_id ||= PusherChannels.instance.channel_name_for_class_id(self.class, _id)
  end

  def num_visitors
  	visitor_ids.try(:count) || 0
  end

  def add_visitor(visitor)
  	raise "nil visitor can not be added" if visitor.nil?
    Thread::exclusive {
	  	self.visitor_ids ||= []
	  	visitor_ids << visitor.id
      save
    }
	end

	def visitors
		return [] if visitor_ids.nil?
		size = visitor_ids.size
		visitor_ids.delete_if {|vid| VISITORS[vid].nil? }
		save if size > visitor_ids.size
	
		visitor_ids.collect {|vid| VISITORS[vid]}
	end

	def visitors_for_display
	  return [] if 0==num_visitors
	  visitors.collect{ |visitor| visitor.for_display }
	end

  def for_display
  	{
  		id: _id,
  		name: name,
  		num_visitors: num_visitors
  	}
  end
end
