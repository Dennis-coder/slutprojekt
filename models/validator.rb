class Validator

    def self.login(params)
        username = params['username']
        plaintext = params['plaintext']
        user = User.new(nil, username)
        user_id = user.id   
		if user_id == nil
			return "No account with that name"
        end
        if BCrypt::Password.new(user.password_hash) == plaintext
			return user_id
		else
			return "Wrong password"
		end
    end

    def self.register(params)
        username = params['username']
        plaintext = params['plaintext']
        plaintext_confirm = params['plaintext_confirm']
        user = User.new(nil, username)
        if user.username != nil
            return "A user with that name already exists"
        elsif username.length < 5
            return "Username has to be 5 characters"
        elsif plaintext.length < 5
            return "Password has to be 5 characters"
		elsif plaintext != plaintext_confirm
			return "Passwords are not the same"
        else
            return true
        end
    end

end