class Validator

    def self.login(username, plaintext)
        user_id = User.id_by_username(username).first

		if user_id == nil
			return "No account with that name"
        end
        
        user_id.first
		password = User.password_by_id(user_id).first.first
        password = BCrypt::Password.new(password)
        
        if password == plaintext
			return user_id.first
		else
			return "Wrong password"
		end
    end

    def self.register(username, plaintext, plaintext_confirm)
        if User.id_by_username(username).first != nil
			return "A user with that name already exists"
		elsif plaintext != plaintext_confirm
			return "Passwords are not the same"
        else
            return true
        end
    end

end