class Application < Sinatra::Base
    
    enable :sessions

	before do 
		@db = SQLite3::Database.new('db/websnap.db')
		@db.results_as_hash = true
		session[:user_id] = 1
	end

	before '/home/?' do
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
		user_id = User.id_by_username(params[:username]).first
		
		if user_id == nil
			session[:login_error] = "No account with that name"		
			redirect '/login'
		end
		
		user_id.first
		password = User.password_by_id(user_id).first.first
		password = BCrypt::Password.new(password)

		if password == params[:plaintext]
			session.delete(:login_error)
			session[:user_id] = user_id
			redirect '/home'
		else
			session[:login_error] = "Wrong password"
			redirect '/login'
		end
	end

	get '/register/?' do
		slim :register
	end

	post '/register' do
		if User.id_by_username(params[:username]).first != nil
			session[:register_error] = "A user with that name already exists"
			redirect '/register'
		elsif params[:plaintext] != params[:plaintext_confirm]
			session[:register_error] = "Passwords are not the same"
			redirect '/register'
		end

		User.add(params[:username], params[:email], params[:plaintext], params[:geotag])
		session[:user_id] = User.id_by_username(params[:username])
		redirect '/home'

	end

	post '/logout' do
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
		@messages = recieved
		slim :friend

	end

end