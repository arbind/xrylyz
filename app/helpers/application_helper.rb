module ApplicationHelper

def clear_from_session(key)
	if session[key]
		val = session[key]
		session.data.delete key
		val
	end
end

def send_to_next_page()  clear_from_session(:send_to_next_page) end
def send_to_next_page=(page) session[:send_to_next_page] = page end
def send_to_prev_page()  clear_from_session(:send_to_prev_page) end
def send_to_prev_page=(page) session[:send_to_prev_page] = page end

end
