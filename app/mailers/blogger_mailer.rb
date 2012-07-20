class BloggerMailer

  EMAIL_HEADER_FROM_ADDRESS = 'play@rylyz.com'
  EMAIL_TEMPLATE_FOR_ACTIVATION = 'activation'

  def self.send_emails_to_bloggers_for_activation(options = {})
    bloggers = bloggers_for_activation(options)
    postageapp_data =  {
            'headers'     => options['headers']  || { 'from' => EMAIL_HEADER_FROM_ADDRESS },
            'template'    => options['template'] || EMAIL_TEMPLATE_FOR_ACTIVATION,
            'recipients'  => postageapp_recipients_for_activation(bloggers)
    }
    postage_app_send_email_template(bloggers, postageapp_data)
  end

  private


  # setup for activation
  def self.bloggers_for_activation(options = {})
    bloggers = options['bloggers'] || RylyzBlogger.all
    recipient_bloggers = bloggers.select do |b|
      b # +++ 
    end
  end
  def self.postageapp_recipients_for_activation(recipient_bloggers)
    util = Object.new.extend(ActionView::Helpers::NumberHelper)

    recipients = {}
    recipient_bloggers.each do |blogger|
      recipients[blogger.email] = {
        'share_key' => blogger.share_key,
        'base_profit_sharing_rate' => "#{util.number_to_percentage(100*blogger.plan.base_profit_sharing_rate, precision: 0)}"
      }
    end
    recipients
  end


  # postage app utils
  def self.postage_app_send_email_template(recipient_bloggers, data)
    response  = PostageApp::Request.new(:send_message, data).send
    stamp_email_history(recipient_bloggers, data['template']) if response.ok?
    puts data
    true
  end

  def self.stamp_email_history(recipient_blogger, template_name)
    # update email history for recipients
    begin
      timestamp = DateTime.now.to_s
      recipient_blogger.each do |blogger|
        template_history = blogger.email_history[template_name] || []
        template_history.push timestamp
        blogger.email_history[template_name] = template_history
        blogger.save
      end
      true
    rescue
      false
    end
  end

end
