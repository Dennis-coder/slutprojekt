class Application < Sinatra::Base
    
    enable :sessions

	before do 
		@db = SQLite3::Database.new('db/websnap.db')
		@db.results_as_hash = true
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
		end

		User.add(params[:username], params[:email], params[:password], params[:geotag])
		session[:user_id] = User.id_by_username(params[:username])
		redirect '/home'

	end

	post '/logout' do
		session.delete(:user_id)
		redirect '/'

	end

    get '/home' do
        slim :home
    end

end