class User < DBEntity

    attr_accessor :id, :username, :password_hash, :admin
    
    def initialize()
        @id = nil
        @username = nil
        @password_hash = nil
        @admin = nil
    end
    
    def add()
        db.execute("INSERT INTO users (username, password_hash, admin) VALUES(?,?,?)", @username, @password_hash, 0)
    end
    
    def friendslist()
        hash_list = db.execute("SELECT user_id, user2_id FROM friends WHERE (user_id = ? OR user2_id = ?) AND status = ?", @id, @id, 0)
        list = []
        hash_list.each do |hash|
            if hash['user_id'] == @id
                list << Friend.get(@id, hash['user2_id'])
            else
                list << Friend.get(@id, hash['user_id'])
            end
        end
        return Sorter.last_interaction(list)
    end

    def groups()
        id_list = db.execute("SELECT group_id FROM groups_handler WHERE user_id = ?", @id)
        groups_list = []
        id_list.each do |id|
            groups_list << Groupchat.get(id['group_id'])
        end
        return Sorter.last_interaction(groups_list)
    end

    def messages(id)
        hash_list = db.execute("SELECT id FROM messages WHERE reciever_id = ? OR sender_id = ?", @id, @id)
        list = []
        hash_list.each do |hash|
            list << Message.get(hash['friends_id'])
        end
        return list
    end

    def self.get(id)
        user = User.new()
        properties = db.execute("SELECT * FROM users WHERE id = ?", id).first
        user.id = properties['id']
        user.username = properties['username']
        user.password_hash = properties['password_hash']
        user.admin = properties['admin']

        return user
    end

    def self.id(username)
        db.execute("SELECT id FROM users WHERE username = ?", username).first['id']
    end

    def self.username(id)
        db.execute("SELECT username FROM users WHERE id = ?", id).first['username']
    end

    def self.all
        db.execute("SELECT id FROM users")
    end

    def self.change_password(id, password)
        db.execute("UPDATE users SET password_hash = ? WHERE id = ?", BCrypt::Password.create(password), id)
    end

    def self.delete(id)
        db.execute("UPDATE users SET username = ? WHERE id = ?", 'Deleted user', id)
        db.execute("DELETE FROM reports WHERE accused = ?", id)
    end
    
end