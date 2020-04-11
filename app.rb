class Application < Sinatra::Base
    
    enable :sessions

	before do 
		# session[:user_id] = 1
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
		result = Validator.login(params)
		if result.is_a? Integer
			session['user_id'] = result
			redirect '/home'
		else
			session['login_error'] = result
			redirect '/login'
		end
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
		if session['time_last_message'] == nil || (Time.now.utc - session['time_last_message']) >= 1
			if Validator.message(params['message']) 
				session['time_last_message'] = Time.now.utc
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

	get '/home/groups/:id' do
		group = Groupchat.new(params['id'])
		slim :group, locals: {group: group}
	end

	get '/api/v1/get/id/:username' do
		return User.id(params['username']).to_json
	end

	get '/api/v1/get/timestamp' do
		return Time.now.utc.to_json
	end

	get '/api/v1/messages/:id/:latest' do
		messages = Friend.new_messages(@user.id, params)
		return messages.to_json
	end

	get '/api/v1/message/send/:message/:reciever' do
		if session['time_last_message'] == nil || (Time.now.utc - session['time_last_message']) >= 1
			if Validator.message(params['message']) 
				session['time_last_message'] = Time.now.utc
				Friend.send_message(params, @user)
			end
		else
			session['message_error'] = "Please wait 1 second before sending another message"
		end
	end

	get '/api/v1/group_message/send/:message/:group_id' do
		if session['time_last_message'] == nil || (Time.now.utc - session['time_last_message']) >= 1
			if Validator.message(params['message']) 
				session['time_last_message'] = Time.now.utc
				Groupchat.send_message(params, @user)
			end
		else
			session['message_error'] = "Please wait 1 second before sending another message"
		end
	end

	get '/api/v1/requests/:user_id/send' do
		Friend.send_request(@user.id, params['user_id'].to_i)
	end

	get '/api/v1/requests/:user_id/accept' do
		Friend.accept_request(@user.id, params['user_id'])
	end

	get '/api/v1/requests/:user_id/delete' do
		Friend.delete(@user.id, params['user_id'])
	end

end