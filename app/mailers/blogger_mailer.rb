require "postageapp"

PostageApp.configure do |config|
  config.api_key = "q0cygShe1yn3h538JDYUNzNZlqbS18Zr"
end

class BloggerMailer
  def self.send_bulk_activation(bloggers)
    data = {
      "headers" => {
        "from"    => "play@rylyz.com",
      },
      "template" => "activation",
      "recipients" => build_recipients(bloggers)
    }
    request = PostageApp::Request.new(:send_message, data)
    response = request.send
  end

  def self.build_recipients(bloggers)
    recipients = {}
    bloggers.each do |blogger|
      recipients[blogger.email] = {
        "share_key" => blogger.share_key,
        "base_profit_sharing_rate" => blogger.plan.base_profit_sharing_rate
      }
    end
    recipients
  end
end
