class Sudo::ControlPanelController < Sudo::SudoController
	require 'csv'


  def test
  #   Speed.of do
  #     visitor = RyVisitor.new
  #     visitor.wid = "xyz-#{DateTime.now}"
  #     game = Quiz::Game.daily_game(visitor)
  #   end


#  =========================
	PusherChannels.instance.setup
# ===================================











    render text:"done at #{DateTime.now}"

  end

	def index
		@members = RylyzMember.all
		@presences = RylyzMemberPresence.all
		@websites = RylyzBloggerSite.all
	end

	def new_bloggers
	end

	def signals
		@channels = PusherChannels.instance.channels
	end

	def signups
		@signups = RylyzBlogger.all
		@plans = RylyzBloggerPlan.all
	end

	def api() end

	def preview_activation_emails
		sent_email_count = BloggerMailer.preview_activation_emails
		redirect_to :sudo_signups, :notice =>"Activation emails would be sent to #{pluralize(sent_email_count, 'people')}!"
	end
	def send_activation_emails
		sent_email_count = BloggerMailer.send_activation_emails
		redirect_to :sudo_signups, :notice =>"Sent emails to #{sent_email_count} people!"
	end

	def load_signups
		# ++++todo get this data directly from launchrock: http://developers.launchrock.com/documentation/api/reference#api-insights
		blogger = nil
		plan = nil

		signup_csv_url = 'https://docs.google.com/spreadsheet/pub?key=0Art_DhjcEo-FdFFzQUk4dUFabklQX3otbF9ybWx3NkE&output=csv'

		CSV.foreach(open(signup_csv_url), :headers=>true) do |r|
			email =  r['email']
			if not email.nil? # each record must have an email address

			  blogger = RylyzBlogger.where(email: email).first # +++ why does find_by not work for mongoid? use where in the meantime
			  if blogger.nil? # create this new blogger
					begin
						dt = DateTime.strptime(r['timestamp'], "%m/%d/%Y %H:%M:%S") if not r['timestamp'].nil?
						last_signup_at = Time.parse(dt.to_s).utc if not dt.nil?
					rescue
					end
					last_signup_at ||= Time.now.utc

				  blogger = RylyzBlogger.new(
				  	email: email,
						share_key: share_key_for_ref_url(r['ref_url']),
						referred_by: r['referred_by'],
						is_early_adopter: true,  #+++ change this after alpha release!!!
						signedup_at: last_signup_at
				  	)
			  end

			  blogger.plan = nil if (blogger.plan and RylyzBloggerPlan::DEFAULT_PLAN_NAME == blogger.plan.name)
			  # bind the blogger's subscription plan
			  blogger.plan = RylyzBloggerPlan.where(name: r['plan_name']).first if blogger.plan.nil?

			  if blogger.plan.nil? # create a new plan if needed
			  	if r['plan_name'] and r['share'] and r['ref'] and r['affil8'] and r['$/month']
					  blogger.plan = RylyzBloggerPlan.create!(
					  	name: r['plan_name'],
							base_profit_sharing_rate: r['share'].to_f/100,
							referral_rate: r['ref'].to_f/100,
							affiliate_rate: r['affil8'].to_f/100,
							monthly_subscription_rate: r['$/month'].to_f
							)
					else
						# back to default plan
					  blogger.plan = RylyzBloggerPlan.where(name: RylyzBloggerPlan::DEFAULT_PLAN_NAME).first
					  blogger.plan ||= RylyzBloggerPlan.create
					end
				end

				# update latest stats for all bloggers
				blogger.share_clicks = r['user_clicks'].to_i if not r['user_clicks'].nil?
				blogger.share_conversions = r['user_signups'].to_i if not r['user_signups'].nil?

				blogger.save!
			end
		end

		redirect_to :sudo_signups
	end

private
	def share_key_for_ref_url(uri)
		params = Rack::Utils.parse_query URI(uri).query
		params['lrRef']
	end

end