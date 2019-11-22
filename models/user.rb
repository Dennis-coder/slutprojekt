class User < DBEntity

    def self.id_by_username(username)
        db.execute("SELECT id FROM users WHERE username = ?", username)
    end

    def self.id_by_email(email)
        db.execute("SELECT id FROM users WHERE email = ?", email)
    end

    def self.username_by_id(id)
        db.execute("SELECT username FROM users WHERE id = ?", id)
    end

    def self.password_by_id(id)
        db.execute("SELECT password_hash FROM users WHERE id = ?", id)
    end

    def self.admin_by_id(id)
        db.execute("SELECT admin FROM users WHERE id = ?", id)
    end

    def self.geotag_by_id(id)
        db.execute("SELECT geotag FROM users WHERE id = ?", id)
    end

    def self.signupdate_by_id(id)
        db.execute("SELECT sign_up_date FROM users WHERE id = ?", id)
    end

    def self.email_by_id(id)
        db.execute("SELECT email FROM users WHERE id = ?", id)
    end

    def self.admin?(id)
        if db.execute("SELECT admin FROM users WHERE id = ?", id) == 1
            return true
        else
            return false
        end
    end

    def self.all_by_id(id)
        db.execute("SELECT * FROM users WHERE id = ?", id)
    end

    def self.add(username, email, password, geotag)
        db.execute("INSERT INTO users (username, email, password_hash, sign_up_date, admin, geotag) VALUES(?,?,?,?,?,?)", username, email, BCrypt::Password.create(password), "#{Time.now}", 0, geotag)
    end

end