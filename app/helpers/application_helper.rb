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

	def next_page_on_success! 
		page = session[:next_page_on_success] # one time access
		clear_next_page_from_session					# clears next_page vars from the session
		page
	end
	def next_page_on_success=(page)
		session[:next_page_on_success] = page
	end

	def next_page_on_failure!
		page = session[:next_page_on_failure]	# one time access
		clear_next_page_from_session					# clears next_page vars from the session
		page

		# +++
		# do not clear on failure - otherwise back button will no longer find value in the session after a failure
		# user may likely hit back button after a failure)

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

end
