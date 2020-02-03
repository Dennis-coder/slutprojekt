class User < DBEntity

    attr_accessor :id, :username, :password_hash, :password_hash, :admin, :sign_up_date

    def initialize(id=nil, username=nil)
        properties = self.properties(id, username)
        if properties != nil
            @id = properties['id']
            @username = properties['username']
            @password_hash = properties['password_hash']
            @admin = properties['admin']
            @signupdate = properties['signupdate']
        end
    end
    
    def properties(id, username)
        if username == nil
            db.execute("SELECT * FROM users WHERE id = ?", id).first
        elsif id == nil
            db.execute("SELECT * FROM users WHERE username = ?", username).first
        end
    end

    def friends_list()
        hash_list = db.execute("SELECT id, user_id, user2_id FROM friends WHERE (user_id = ? OR user2_id = ?) AND status = ?", @id, @id, 0)
        list = []
        hash_list.each do |hash|
            if hash['user_id'] == @id
                list << Friend.new(hash['user2_id'], hash['id'])
            else
                list << Friend.new(hash['user_id'], hash['id'])
            end
        end
        return list
    end

    def messages(id)
        hash_list = db.execute("SELECT id FROM messages WHERE reciever_id = ? OR sender_id = ?", @id, @id)
        list = []
        hash_list.each do |hash|
            list << Message.new(hash['friends_id'])
        end
        return list
    end
    
    def self.just_id(username)
        db.execute("SELECT id FROM users WHERE username = ?", username).first['id']
    end

    def self.just_username(id)
        db.execute("SELECT username FROM users WHERE id = ?", id).first['username']
    end

    def self.all
        db.execute("SELECT id FROM users")
    end

    def self.add(params)
        db.execute("INSERT INTO users (username, password_hash, sign_up_date, admin) VALUES(?,?,?,?)", params['username'], BCrypt::Password.create(params['plaintext']), "#{Time.now.utc}", 0)
    end
    
end