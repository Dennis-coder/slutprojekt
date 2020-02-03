class Validator

    def self.login(params)
        username = params['username']
        plaintext = params['plaintext']
        user = User.new(nil, username) 
		if user.id == nil
			return "Wrong username or password"
        end
        if BCrypt::Password.new(user.password_hash) == plaintext
			return user.id
		else
			return "Wrong username or password"
		end
    end

    def self.register(params)
        username = params['username']
        plaintext = params['plaintext']
        plaintext_confirm = params['plaintext_confirm']
        allowed_chars = ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z","1","2","3","4","5","6","7","8","9","0"]
        user = User.new(nil, username)
        username.downcase.each_char do |char|
            if allowed_chars.index(char) == nil
                return "No special characters, only a-z and 0-9 are allowed"
            end
        end
        plaintext.downcase.each_char do |char|
            if allowed_chars.index(char) == nil
                return "No special characters, only a-z and 0-9 are allowed"
            end
        end
        if user.username != nil
            return "A user with that name already exists"
        elsif username.length < 1 || username.length > 16
            return "Username has to be between 1-16 characters"
        elsif plaintext.length < 5
            return "Password has to be 5 characters or more"
		elsif plaintext != plaintext_confirm
			return "Passwords are not the same"
        else
            return true
        end
    end

    def self.message(text)
        if text == nil
            return nil
        else
            text.each_char do |char|
                if char != " "
                    return true
                end
            end

            return false
        end
    end

end