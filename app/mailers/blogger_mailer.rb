class BloggerMailer

  FROM_ADDRESS        = 'play@rylyz.com'
  LOG_SCOPE           = 'email-to-blogger'
  ACTIVATION_TEMPLATE = 'activation'

  def self.preview_activation_emails(options = {})
    bloggers_for_activation(options).count
  end

  def self.send_activation_emails(options = {})
    blogger_recipients = bloggers_for_activation(options)
    return 0 if blogger_recipients.empty?
    
    postageapp_recipients = postageapp_recipients_for_activation(blogger_recipients)
    send_email(ACTIVATION_TEMPLATE, postageapp_recipients, blogger_recipients, options)
  end

  private

  # setup for activation
  def self.bloggers_for_activation(options = {})
    bloggers = options['bloggers'] || RylyzBlogger.all

    blogger_recipients = bloggers.reject do |blogger|
      blogger.do_not_email or
      not blogger.member.nil? or
      TimestampLogger.last_stamped_after?(LOG_SCOPE, blogger.id, ACTIVATION_TEMPLATE, 15.days.ago)
    end
  end

  def self.postageapp_recipients_for_activation(blogger_recipients)
    postageapp_recipients = {}
    blogger_recipients.each do |blogger|
      profit_sharing_rate = Util::percentage(blogger.plan.base_profit_sharing_rate)
      postageapp_recipients[blogger.email] = {
        'share_key' => blogger.share_key,
        'base_profit_sharing_rate' => profit_sharing_rate
      }
    end
    postageapp_recipients
  end


  # postage app utils
  def self.send_email(template, postageapp_recipients, bloggers, options)
    postageapp_data =  {
            'headers'     => options['headers']  || { 'from' => FROM_ADDRESS },
            'template'    => template,
            'recipients'  => postageapp_recipients
    }
    postage_app_send_email_template(bloggers, postageapp_data)
  end

  def self.postage_app_send_email_template(blogger_recipients, data)
    d = limit_recipients_if_testing(data)
    response  = PostageApp::Request.new(:send_message, d).send
    stamp_email_history(blogger_recipients, data['template']) if response.ok?
  end

  def self.limit_recipients_if_testing(data)
    return data if PostageApp.config.recipient_override.blank?
    # limit recipients to only 1 real person plus spirit+001 - spirit+005@rylyz.com if in test mode
    # all test emails will actually end up going to value of PostageApp.config.recipient_override (which is set to spirit+000@rylyz.com)
    test_recipients = {}    
    (1..5).to_a.each do |n|
      email = "spirit+00#{n}@rylyz.com"
      test_recipients[email] = data['recipients'][email] unless data['recipients'][email].nil?
    end
    one_real_recipient = data['recipients'].first # get key, value of first recipient
    test_recipients[one_real_recipient[0]] = one_real_recipient[1] unless one_real_recipient.nil?

    puts "IN TESTMODE: postageapp is configured to override email recipients. sending only #{test_recipients.count} emails instead of all #{data['recipients'].count}."

    data['recipients'] = test_recipients
    data
  end

  # utils
  def self.stamp_email_history(blogger_recipients, template_name)
    # update email history for recipients
    begin
      timestamp = DateTime.now
      blogger_recipients.each do |blogger|
        TimestampLogger.stamp(LOG_SCOPE, blogger.id, template_name, timestamp)
      end
      puts "o-- Just sent #{template_name} email to #{blogger_recipients.count} people!"
      blogger_recipients.count
    rescue
      0
    end
  end

end
