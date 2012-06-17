require "Rack"
require "URI"

class Sudo::ControlPanelController < ApplicationController
	layout "sudo"
	http_basic_authenticate_with :name => "rylyz.games", :password => "play.well" 

	def index

	end

	def new_bloggers

	end

	def signups
		@signups = RylyzBlogger.all
	end

	def api() end
		
	def load_signups
		require 'csv'
		require 'open-uri'
		blogger = nil
		plan = nil
		last_signup_at = DateTime.now 

		signup_csv_url = 'https://docs.google.com/spreadsheet/pub?key=0Art_DhjcEo-FdFFzQUk4dUFabklQX3otbF9ybWx3NkE&output=csv'

		CSV.foreach(open(signup_csv_url), :headers=>true) do |r|
			email =  r['email']
			if not email.nil?
			  blogger = RylyzBlogger.find_or_create_by(email: email)

			  blogger.plan = RylyzBloggerPlan.create if blogger.plan.nil?
				blogger.plan.profit_sharing_rate ||= r['share'].to_f/100 if r['share']
				blogger.plan.referral_rate ||= r['ref'].to_f/100 if r['ref']
				blogger.plan.monthly_subscription_rate ||= r['$/month'].to_f if r['$/month']

				# +++ todo: blogger.is_early_adopter = 

				blogger.plan.save!

			  blogger.is_alpha_tester = r['alpha']
				blogger.hi_email_sent ||= r['hi']
				blogger.referred_by = r['referred_by']
				blogger.share_key ||= share_key_for_ref_url(r['ref_url'])

				blogger.share_clicks = r['user_clicks'].to_i if r['user_clicks']
				blogger.share_conversions = r['user_signups'].to_i if r['user_signups']
				begin
					last_signup_at = DateTime.strptime(r['timestamp'], "%m/%d/%Y %H:%M:%S") if r['timestamp']
				rescue
					# If DateTime fails to parse, just use the last_signup_time
				ensure
					blogger.signup_at = last_signup_at
				end
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