module ApplicationHelper

	def member_has_valid_credit_card?
		cards = current_member.credit_cards
		card = cards.first unless cards.nil?
		# +++ check if card is valid and hasn't expired
	end

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
<div id='rylyz-wygyt' style='font-size:1px;'><a href='http://rylyz.com'>play games online</a></div>
EOL
  	code.html_safe
  end

end
