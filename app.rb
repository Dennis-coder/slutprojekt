class Application < Sinatra::Base
    
    enable :sessions

	before do 
		@db = SQLite3::Database.new('db/websnap.db')
		@db.results_as_hash = true
		# session[:user_id] = 1
	end

	before '/home/?' do
		if session[:user_id] == nil
			redirect '/'
		end
	end

	before '/friend/*' do
		if session[:user_id] == nil
			redirect '/'
		end
	end
	
    get '/?' do
        slim :index
    end

    get '/login/?' do
        slim :login
    end

	post '/login' do
		returned = Validator.login(params[:username], params[:plaintext])
		if returned.is_a? Integer
			session[:user_id] = returned
			redirect '/home'
		else
			session[:login_error] = returned
			redirect '/login'
		end
	end

	get '/register/?' do
		slim :register
	end

	post '/register' do
		returned = Validator.register(params[:username], params[:plaintext], params[:plaintext_confirm])
		if returned == true
			User.add(params[:username], params[:email], params[:plaintext], params[:geotag])
			session[:user_id] = User.id_by_username(params[:username])
			redirect '/home'
		else
			session[:register_error] = returned
			redirect '/register'
		end
	end

	get '/logout' do
		session.delete(:user_id)
		redirect '/'
	end

	get '/home' do
		friends_id = Friend.friendslist(session[:user_id])
		@friends = []
		unless friends_id.empty?
    		friends_id.each do |friend_id|
        		friend = User.username_by_id(friend_id)
        		friend << Friend.last_interaction(session[:user_id], friend_id).first
				@friends << friend
			end
			@friends.first
		end
		slim :home
		
	end
	
	get '/friend/:username/?' do

		recieved = Message.messages(session[:user_id], User.id_by_username(params[:username]))
		sent = Message.messages(User.id_by_username(params[:username]), session[:user_id])
		@messages = Sorter.messages(recieved, sent)
		slim :conversation

	end

	post '/friend/:reciever/send' do

		Message.send(params[:message], User.geotag_by_id(session[:user_id]), session[:user_id], User.id_by_username(params[:reciever]))
		redirect "/friend/#{params[:reciever]}"

	end

end