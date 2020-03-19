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
		returned = Validator.login(params)
		if returned.is_a? Integer
			session['user_id'] = returned
			redirect '/home'
		else
			session['login_error'] = returned
			redirect '/login'
		end
	end

	get '/register/?' do
		slim :register
	end

	post '/register' do
		returned = Validator.register(params)
		if returned == true
			User.add(params)
			session['user_id'] = User.just_id(params['username'])
			redirect '/home'
		else
			session['register_error'] = returned
			redirect '/register'
		end
	end

	get '/logout/?' do
		session.delete('user_id')
		redirect '/'
	end

	get '/home/?' do
		friends = Sorter.last_interaction(@user.friendslist)
		slim :home, locals: {friends: friends}
	end
	
	get '/home/friends/:username/?' do
		messages = Message.conversation(session['user_id'], User.just_id(params['username']))
		slim :conversation, locals: {messages: messages}
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
		results = Search.find_friends(@user, params['term'])
		slim :friendSearch, locals: {results: results}
	end
	
	get '/home/find_user' do
		results = Friend.pending_requests(@user.id)
		slim :search, locals: {results: results}
	end

	post '/home/find_user' do
		if params['search_term'] == ""
			redirect '/home/find_user'
		else
			redirect "/home/find_user/#{params['search_term']}"
		end
	end

	get '/home/find_user/:search_term/?' do
		results = Search.find_users(params['search_term'], @user.id)
		slim :search, locals: {results: results}
	end

	get '/home/new_chat/?' do
		if session['chat_list'] == nil
			session['chat_list'] = []
		end
		friends = Sorter.alphabetical(@user.friendslist)
		slim :newChat, locals: {friends: friends}
	end

	post '/home/new_chat' do
		list = session['chat_list']
		session['chat_list'] = nil
		if list.length == 1
			redirect "/home/friends/#{User.just_username(list.first.to_i)}"
		elsif list.length > 1

		else

			redirect "/home/new_chat"
		end
	end

	get '/api/v1/get/id/:username' do
		return User.just_id(params['username']).to_json
	end

	get '/api/v1/get/timestamp' do
		return Time.now.utc.to_json
	end

	get '/api/v1/messages/:id/:latest' do
		messages = Message.new_messages(session['user_id'], params)
		return messages.to_json
	end

	get '/api/v1/message/send/:message/:reciever' do
		if session['time_last_message'] == nil || (Time.now.utc - session['time_last_message']) >= 1
			if Validator.message(params['message']) 
				session['time_last_message'] = Time.now.utc
				Message.send(params, @user)
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

	get '/api/v1/newChat/add/:user_id' do
		session['chat_list'] << params['user_id']
	end

	get '/api/v1/newChat/remove/:user_id' do
		session['chat_list'].delete(params['user_id'])
	end

end