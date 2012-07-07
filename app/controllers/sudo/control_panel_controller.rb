require "uri"

class Sudo::ControlPanelController < Sudo::SudoController
	
	def index

	end

	def new_bloggers

	end

	def signups
		@signups = RylyzBlogger.all
	end

	def api() end
		
	def load_signups
		# ++++todo get this data directly from launchrock: http://developers.launchrock.com/documentation/api/reference#api-insights

		require 'csv'
		require 'open-uri'
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

			  # bind the blogger's subscription plan
			  blogger.plan = RylyzBloggerPlan.where(name: r['plan_name']).first if blogger.plan.nil?
			  if blogger.plan.nil? # create a new plan if needed
				  blogger.plan = RylyzBloggerPlan.create!(
				  	name: r['plan_name'],
						base_profit_sharing_rate: r['share'].to_f/100,
						referral_rate: r['ref'].to_f/100,
						affiliate_rate: r['affil8'].to_f/100,
						monthly_subscription_rate: r['$/month'].to_f
						)
				end

				# update latest stats for all bloggers
				blogger.share_clicks = r['user_clicks'].to_i if not r['user_clicks'].nil?
				blogger.share_conversions = r['user_signups'].to_i if not r['user_signups'].nil?

				blogger.save!
			end
		end

		@signups = RylyzBlogger.all
		redirect_to :sudo_signups
	end

private
	def share_key_for_ref_url(uri)
		params = Rack::Utils.parse_query URI(uri).query
		params['lrRef']
	end

end