class Application < Sinatra::Base
    
    enable :sessions

	before do 
		p "hej"
		if DBTest.start == false && session['db_connection'] != false
			session['db_connection'] = false
			redirect "/error"
		end
		if session['user_id'] != nil
			@user = User.new(session['user_id'])
		end
	end

	before '/home/?' do
		if session['user_id'] == nil
			redirect '/'
		end
	end

	before '/home/*' do
		if session['user_id'] == nil
			redirect '/'
		end
	end

	before '/home/admin/?' do
		if @user.admin != 1
			redirect '/home'
		end
	end

	before '/home/admin/*' do
		if @user.admin != 1
			redirect '/home'
		end
	end

	before '/error' do
		if DBTest.start == true
			session['db_connection'] = true
			redirect '/'
		end
	end

	get '/?' do
		if session['user_id'] != nil
			redirect '/home'
		end
        slim :index
    end

	get '/login/?' do
        slim :login
    end

	post '/login' do
		login_cooldown = 3
		if session['last_login'] == nil || (Time.now - session['last_login']) >= login_cooldown
			result = Validator.login(params)
			session['last_login'] = Time.now
			if result.is_a? Integer
				session['user_id'] = result
				redirect '/home'
			else
				session['login_error'] = result
			end
		else
			session['login_error'] = "You have to wait #{login_cooldown - (Time.now - session['last_login']).ceil} second(s) before trying again"
		end
		redirect '/login'
	end

	get '/register/?' do
		slim :register
	end

	post '/register' do
		result = Validator.register(params)
		if result == true
			User.add(params)
			session['user_id'] = User.id(params['username'])
			redirect '/home'
		else
			session['register_error'] = result
			redirect '/register'
		end
	end

	get '/logout/?' do
		session.delete('user_id')
		redirect '/'
	end

	get '/home/?' do
		slim :home, locals: {friends: @user.friendslist, groups: @user.groups}
	end
	
	get '/home/friends/:username/?' do
		slim :conversation, locals: {friend: Friend.new(@user.id, User.id(params['username']))}
	end

	post '/home/friends/:reciever/send' do
		if session['time_last_message'] == nil || (Time.now - session['time_last_message']) >= 1
			if Validator.message(params['message']) 
				session['time_last_message'] = Time.now
				Message.send(params, @user)
			end
		else
			session['message_error'] = "Please wait 1 second before sending another message"
		end
		redirect "/home/friends/#{params['reciever']}"
	end

	post '/home/friends/search' do
		if params['search_term'] == ""
			redirect '/home'
		else
			redirect "/home/friends/search/#{params['search_term']}"
		end
	end

	get '/home/friends/search/:term/?' do
		slim :friendSearch, locals: {results: Search.find_friends(@user, params['term'])}
	end
	
	get '/home/find_user' do
		slim :search, locals: {results: Friend.pending_requests(@user.id)}
	end

	post '/home/find_user' do
		if params['search_term'] == ""
			redirect '/home/find_user'
		else
			redirect "/home/find_user/#{params['search_term']}"
		end
	end

	get '/home/find_user/:search_term/?' do
		slim :search, locals: {results: Search.find_users(params['search_term'], @user.id)}
	end

	get '/home/new_chat/?' do
		slim :newChat, locals: {friends: Sorter.alphabetical(@user.friendslist)}
	end

	post '/home/new_chat' do
		if params.length == 1
			redirect "/home/friends/#{User.username(params.first.last.to_i)}"
		elsif params.length > 1
			params[@user.username] = @user.id
			group_id = Groupchat.create(params)
			redirect "/home/groups/#{group_id}"
		else
			redirect "/home/new_chat"
		end
	end

	get '/home/groups/:id/?' do
		group = Groupchat.new(params['id'])
		slim :group, locals: {group: group}
	end

	get '/home/settings/?' do
		slim :settings
	end

	post '/home/settings/change_password' do
		result = Validator.change_password(@user.password_hash, params)
		if result == true
			User.change_password(@user.id, params['new_password'])
			session['settings_error'] = "The change was successful"
		else
			session['settings_error'] = result
		end
		redirect 'home/settings'
	end

	post '/home/settings/report' do
		result = Validator.report(@user, params)
		if result == true
			Report.send(@user.id, params)
			session['settings_error'] = "Your report has been sent"
		else
			session['settings_error'] = result
		end
		redirect 'home/settings'
	end

	get '/home/admin/?' do
		reports = Report.get_all()
		slim :admin, locals: {reports: reports}
	end

	get '/error/?' do 
		slim :db_error
	end

	get '/api/get/id/:username' do
		return User.id(params['username']).to_json
	end

	get '/api/get/timestamp' do
		return Time.now.to_json
	end

	get '/api/messages/:id/:latest' do
		messages = Friend.new_messages(@user.id, params)
		return messages.to_json
	end

	get '/api/group_messages/:group_id/:latest' do
		messages = Groupchat.new_messages(@user.id, params)
		return messages.to_json
	end

	get '/api/message/send/:message/:reciever' do
		if session['time_last_message'] == nil || (Time.now - session['time_last_message']) >= 1
			if Validator.message(params['message']) 
				session['time_last_message'] = Time.now
				Friend.send_message(params, @user)
			end
		else
			session['message_error'] = "Please wait 1 second before sending another message"
		end
	end

	get '/api/group_message/send/:message/:group_id' do
		if session['time_last_message'] == nil || (Time.now - session['time_last_message']) >= 1
			if Validator.message(params['message']) 
				session['time_last_message'] = Time.now
				Groupchat.send_message(params, @user)
			end
		else
			session['message_error'] = "Please wait 1 second before sending another message"
		end
	end

	get '/api/requests/:user_id/send' do
		Friend.send_request(@user.id, params['user_id'].to_i)
	end

	get '/api/requests/:user_id/accept' do
		Friend.accept_request(@user.id, params['user_id'])
	end

	get '/api/requests/:user_id/delete' do
		Friend.delete(@user.id, params['user_id'])
	end

	get '/api/admin/delete_user/:id' do
		if params['id'] == session['user_id']
			session.delete('user_id')
		end
		User.delete(params['id'])
	end

	get '/api/admin/remove_report/:id' do
		Report.delete(params['id'])
	end

end