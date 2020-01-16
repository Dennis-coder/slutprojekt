class Application < Sinatra::Base
    
    enable :sessions

	before do 
		# session[:user_id] = 1
	end

	before '/home/?' do
		if session['user_id'] == nil
			redirect '/'
		else
			@user = User.new(session['user_id'])
		end
	end

	before '/home/*' do
		if session['user_id'] == nil
			redirect '/'
		else
			@user = User.new(session['user_id'])
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
		friends = @user.friends_list
		slim :home, locals: {friends: friends}
	end
	
	get '/home/friends/:username/?' do
		messages = Message.conversation(session['user_id'], User.just_id(params['username']))
		slim :conversation, locals: {messages: messages}
	end

	post '/home/friends/:reciever/send' do
		Message.send(params, @user)
		redirect "/home/friends/#{params['reciever']}"
	end

	post '/home/friends/search' do
		redirect "/home/friends/search/#{params['search_term']}"
	end

	get '/home/friends/search/:term/?' do
		results = Search.find_friends(@user, params['term'])
		slim :friend_search, locals: {results: results}
	end
	
	get '/home/find_user' do
		results = Friend.pending_requests(@user.id)
		slim :search, locals: {results: results}
	end

	post '/home/find_user' do
		redirect "/home/find_user/#{params['search_term']}"
	end

	get '/home/find_user/:search_term/?' do
		results = Search.find_users(params['search_term'])
		slim :search, locals: {results: results}
	end

	post '/home/requests/:user_id/send' do
		Debug.put(@user.id)
		Debug.put(params['user_id'].to_i)
		Friend.send_request(@user.id, params['user_id'].to_i)
		redirect "/home/find_user"
	end

	post '/home/requests/:user_id/accept' do
		Friend.accept_request(@user.id, params['user_id'])
		redirect "/home/find_user"
	end

	post '/home/requests/:user_id/delete' do
		Friend.delete(@user.id, params['user_id'])
		redirect "/home/find_user"
	end

	get '/home/new_chat/?' do
		slim :new_chat
	end

	get '/api/v1/get/user_id' do
		return session['user_id'].to_json
	end

	get '/api/v1/message/:message_id/sender' do
		out = Message.sender(params['message_id']).first.first
		out = User.username(out).first.first
		return out.to_json
	end

	get '/api/v1/users/:id/messages/:latest' do
		messages = Message.new_messages(session['user_id'], params['id'], params['latest']).reverse
		return messages.to_json
	end

end