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
			session['user_id'] = user.id
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
		friends = @user.friendslist
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
		slim :search, locals: {results: nil}
	end

	get '/home/search/:search_term/?' do



	end

	get '/home/new/chat/?' do
		slim :newChat
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