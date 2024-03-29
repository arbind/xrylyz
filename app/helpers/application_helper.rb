module ApplicationHelper

	def member_has_valid_credit_card?
		cards = current_member.credit_cards
		card = cards.first unless cards.nil?
		# +++ check if card is valid and hasn't expired
	end


	# turn_widget_off
	# make sure to point wygyt to a differnt domain than the website (i.e. holodeck.rylyz.com could use wygyt-holodeck.rylyz..com)
	# the widget may take over the session if pointing to same domain (holodeck, rylyz-local, etc)
	# also - you can use this method in any controller action to not show the widge for that page
  def turn_widget_off() @do_not_show_widget = true end

	# page flow navigation helpers
	def clear_next_page_from_session() # clears next_page vars from the session
		session.delete :next_page_on_success
		session.delete :next_page_on_failure
	end

	def next_page_on_success
		page = session[:next_page_on_success]
	end
	def next_page_on_success=(page)
		session[:next_page_on_success] = page
	end

	def next_page_on_failure
		page = session[:next_page_on_failure]
	end

	def next_page_on_failure=(page)
		session[:next_page_on_failure] = page
	end


	def layout_on_render! 
		layout = session[:layout_on_render] 	# one time access
		session.delete :next_page_on_failure	# clears next_page vars from the session
		layout
	end

	def layout_on_render=(layout)
		session[:layout_on_render] = layout
	end


  def wygyt_code_snippet (rylyz_blogger_site)
    code =<<EOL
<script src='http://wygyt.rylyz.ws/assets/wygyt.js?sitekey=#{rylyz_blogger_site.site_key}' type='text/javascript'></script>
EOL
# add a backlink at some point to get some seo juice for ourselves
# <div id='rylyz-wygyt' style='font-size:1px;'><a href='http://www.rylyz.com'>play games online</a></div>
  	code.html_safe
  end

end
