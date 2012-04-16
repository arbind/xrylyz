class Sudo::ControlPanelController < ApplicationController

	def signups
		@signups = RylyzBlogger.all
	end

	def load_signups
		require 'csv'
		require 'open-uri'
		blogger = nil
		plan = nil
		last_signup_at = nil

		signup_csv_url = 'https://docs.google.com/spreadsheet/pub?key=0Art_DhjcEo-FdFFzQUk4dUFabklQX3otbF9ybWx3NkE&output=csv'

		CSV.foreach(open(signup_csv_url), :headers=>true) do |r|
			email =  r['email']
			if not email.nil?
			  blogger = RylyzBlogger.find_or_create_by(email: email)

			  blogger.plan = RylyzBloggerPlan.create if blogger.plan.nil?
				blogger.plan.profit_sharing_rate ||= r['share'].to_f/100 if r['share']
				blogger.plan.referral_rate ||= r['ref'].to_f/100 if r['ref']
				blogger.plan.monthly_subscription_rate ||= r['$/month'].to_f if r['$/month']
				blogger.plan.save!

			  blogger.is_alpha_tester = r['alpha']
				blogger.hi_email_sent ||= r['hi']
				blogger.referred_by = r['referredby']
				blogger.share_url ||= r['uniqueUrl']
				blogger.share_clicks = r['clicks'].to_i if r['clicks']
				blogger.share_conversions = r['conversions'].to_i if r['conversions']
				blogger.signup_ip = r['orig_ip']
				begin
					last_signup_at = DateTime.strptime(r['timestamp'], "%m/%d/%Y %H:%M:%S") if r['timestamp']
				rescue
					# If DateTime fails to parse, just copy the last_signup_time
				ensure
					blogger.signup_at = last_signup_at
				end
				blogger.save!
			end
		end

		@signups = RylyzBlogger.all
		redirect_to [:sudo, :sudo_signups]
	end

end