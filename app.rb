require_relative 'models/DBEntity.rb'
Dir.glob('models/*.rb') { |model| require_relative model }

class Application < Sinatra::Base
    
    enable :sessions

    # Public: Checks the connection to the database and gets a user
    #
	# DBTest  - The class for the test.
	# session['db_error'] - True or False depending on if there is an error with the connection to the database
	# session['user_id'] - Your user id if you are logged in.
	# @user - Your own user.
	before do 
		if DBTest.connection == false && session['db_error'] == nil
			session['db_error'] = true
			redirect "/error"
		elsif session['db_error'] == true
			session.delete('db_error')
		end
		if session['user_id'] != nil
			@user = User.get(session['user_id'])
		end
	end

	# Public: Checks if you are logged in.
    #
    # session['user_id'] - Your user id if you are logged in.
	before '/home/?' do
		if session['user_id'] == nil
			redirect '/'
		end
	end

	# Public: Checks if you are logged in.
    #
    # session['user_id'] - Your user id if you are logged in.
	before '/home/*' do
		if session['user_id'] == nil
			redirect '/'
		end
	end

	# Public: Checks if you are an admin.
    #
    # @user - Your own user.
	before '/home/admin/?' do
		if @user.admin != 1
			redirect '/home'
		end
	end

	# Public: Checks if you are an admin.
    #
    # @user - Your own user.
	before '/home/admin/*' do
		if @user.admin != 1
			redirect '/home'
		end
	end

	# Public: Checks the connection to the databse after already having an error.
    #
    # DBTest - The class for the test.
	before '/error' do
		if DBTest.connection == true
			session.delete('db_error')
			redirect '/'
		end
	end

	# Public: Checks if you are already logged in
    #
    # session['user_id'] - Your user id if you are logged in.
	get '/?' do
		if session['user_id'] != nil
			redirect '/home'
		end
        slim :index
    end

	# Public: The login page.
	get '/login/?' do
        slim :login
    end

	# Public: Validates you login information and logs you in if they are correct.
    #
	# login_cooldown - The time you have to wait between login attempts in seconds.
	# session['last_login'] - Stores the time of your last login attempt.
	# result - Gets either an error or the user id from the validator.
	# Validator - The class that controls the validation of the user's inputs.
	# params - the login information
	# session['login_error'] - An error message that is displayed on the login page.
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

	# Public: The register page.
	get '/register/?' do
		slim :register
	end

	# Public: Validates the register information.
    #
	# result - Gets either an error or True from the validation.
	# params - the register information.
	# user - the new user to be registered.
	# session['user_id'] - Your user id.
	# session['register_error'] - An error message that is displayed on the register page.
	post '/register' do
		result = Validator.register(params)
		if result == true
			user = User.new()
			user.username = params['username']
			user.password_hash = BCrypt::Password.create(params['plaintext'])
			user.add()

			session['user_id'] = User.id(user.username)
			redirect '/home'
		else
			session['register_error'] = result
			redirect '/register'
		end
	end

	# Public: Logs you out from the website.
	# 
	# session['user_id'] - Your user id.
	get '/logout/?' do
		session.delete('user_id')
		redirect '/'
	end

	# Public: The home page.
	# 
	# @user - Your own user.
	get '/home/?' do
		slim :home, locals: {friends: @user.friendslist, groups: @user.groups}
	end
	
	# Public: The conversation with a friend.
	# 
	# Friend - The class that handles friends.
	# @user - Your own user.
	# params['username'] - The username of the friend.
	get '/home/friends/:username/?' do
		slim :conversation, locals: {friend: Friend.get(@user.id, User.id(params['username']))}
	end

	# Public: Checks if the searchterm is empty and redirects accordingly.
	# 
	# params['search_term'] - The term the user wrote to search for.
	post '/home/friends/search' do
		if params['search_term'] == ""
			redirect '/home'
		else
			redirect "/home/friends/search/#{params['search_term']}"
		end
	end

	# Public: The search results page for friends with the results.
	# 
	# @user - Your own user.
	# params['term'] - The searchterm.
	# Search - the class that handles search functions.
	get '/home/friends/search/:term/?' do
		slim :friend_search, locals: {results: Search.find_friends(@user, params['term'])}
	end
	
	# Public: The find a user page.
	# 
	# @user - Your own user.
	# Friend - the class that handles friends.
	get '/home/find_user' do
		slim :search, locals: {results: Friend.pending_requests(@user.id)}
	end

	# Public: Checks if the searchterm is empty and redirects accordingly.
	# 
	# params['search_term'] - The term the user wrote to search for.
	post '/home/find_user' do
		if params['search_term'] == ""
			redirect '/home/find_user'
		else
			redirect "/home/find_user/#{params['search_term']}"
		end
	end

	# Public: The results page for finding a user with the results.
	# 
	# @user - Your own user.
	# params['searchterm'] - The searchterm.
	# Search - The class that handles search functions.
	get '/home/find_user/:search_term/?' do
		slim :search, locals: {results: Search.find_users(params['search_term'], @user.id)}
	end

	# Public: The new groupchat page.
	# 
	# @user - Your own user.
	# Sorter - The class that handles sorting functions.
	get '/home/new_chat/?' do
		slim :new_chat, locals: {friends: Sorter.alphabetical(@user.friendslist)}
	end

	# Public: Checks how many are in the groupchat and makes one if there are more than 1.
	# 
	# params - Contains all the users to be added.
	# User - The class that handles all the user functions
	# group - The new group.
	# Groupchat - The class that handles the groupchat functions.
	# @user - Your own user.
	post '/home/new_chat' do
		if params.length == 1
			redirect "/home/friends/#{User.username(params.first.last.to_i)}"
		elsif params.length > 1
			group = Groupchat.new()
			group.name = params['group_name']
			params.delete('group_name')
			params[@user.username] = @user.id
			group.users = params
			group_id = group.add
			redirect "/home/groups/#{group_id}"
		else
			redirect "/home/new_chat"
		end
	end

	# Public: The groupchat page.
	get '/home/groups/:id/?' do
		group = Groupchat.get(params['id'])
		slim :group, locals: {group: group}
	end

	# Public: The settings page.
	get '/home/settings/?' do
		slim :settings
	end

	# Public: Validates the password data and changes the password.
	# 
	# result - Is True or False depending on the validation.
	# Validator - The class that handles all user inputs and validates them.
	# @user - Your own user.
	# params - Contains the user inputs.
	# User - The class that handles all user functions.
	# session['settings_error'] - An error that gets displayed in the settings page.
	post '/home/settings/change_password' do
		result = Validator.change_password(@user.password_hash, params)
		if result == true
			User.change_password(@user.id, params['new_password'])
			session['settings_error'] = "The change was successful"
		else
			session['settings_error'] = result
		end
		redirect '/home/settings'
	end

	# Public: Validates the report data and sends the report.
	# 
	# result - Is True or False depending on the validation.
	# Validator - The class that handles all user inputs and validates them.
	# @user - Your own user.
	# params - Contains the user inputs.
	# report - The new report to be sent.
	# Report - The class that handles all report functions.
	# session['settings_error'] - An error that gets displayed in the settings page.
	post '/home/settings/report' do
		result = Validator.report(@user, params)
		if result == true
			report = Report.new
			report.accuser = @user.id
			report.accused = User.id(params['username'])
			report.reason = params['reason']
			report.send
			session['settings_error'] = "Your report has been sent"
		else
			session['settings_error'] = result
		end
		redirect '/home/settings'
	end

	# Public: The admins only page.
	get '/home/admin/?' do
		reports = Report.get_all
		slim :admin, locals: {reports: reports}
	end

	# Public: The connection error page.
	get '/error/?' do 
		slim :db_error
	end


	# Public: Gets the user id for a user.
	# 
	# User - The class that handles all user functions.
	# params['username'] - The username of the user whose id we want.
	# 
	# Returns the id.
	get '/api/get/id/:username' do
		return User.id(params['username']).to_json
	end

	# Public: Gets the current time.
	# 
	# Returns the time.
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

	get '/api/message/send/:type/:text/:reciever' do
		if session['time_last_message'] == nil || (Time.now - session['time_last_message']) >= 1
			if Validator.message(params['text']) 
				session['time_last_message'] = Time.now
				msg = Message.new()
				msg.text = params['text']
				msg.sender_id = @user.id
				msg.reciever_id = params['reciever']
				msg.group_id = params['reciever']
				msg.type = params['type']
				msg.send
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