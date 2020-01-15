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
	
	get '/home/friend/:username/?' do
		messages = Message.conversation(session['user_id'], User.just_id(params['username']))
		slim :conversation, locals: {messages: messages}
	end

	post '/home/friend/:reciever/send' do
		Message.send(params, @user)
		redirect "/home/friend/#{params['reciever']}"
	end
	
	get '/home/search/?' do
		results = Friend.pending_requests(@user.id)
		slim :search, locals: {results: results}
	end

	post '/home/search' do
		redirect "/home/search/#{params['search_term']}"
	end

	get '/home/search/:search_term/?' do
		results = Search.find_friends(params['search_term'])
		slim :search, locals: {results: results}
	end

	post '/home/:user_id/add' do
		Friend.send_request(@user.id, params['user_id'])
		redirect "/home/search/#{params['search_term']}"
	end

	post '/home/:user_id/accept' do
		Friend.accept_request(@user.id, params['user_id'])
		redirect "/home/search/#{params['search_term']}"
	end

	get '/home/new/chat/?' do
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