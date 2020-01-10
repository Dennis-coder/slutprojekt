class User < DBEntity

    attr_accessor :id, :username, :password_hash, :password_hash, :admin, :geotag, :sign_up_date, :friendslist

    def initialize(id=nil, username=nil)
        properties = self.properties(id, username)
        if properties != nil
            @id = properties['id']
            @username = properties['username']
            @password_hash = properties['password_hash']
            @admin = properties['admin']
            @geotag = properties['geotag']
            @signupdate = properties['signupdate']
            @friendslist = self.friends_list()
        end
    end
    
    def properties(id, username)
        if username == nil
            self.db.execute("SELECT * FROM users WHERE id = ?", id).first
        elsif id == nil
            self.db.execute("SELECT * FROM users WHERE username = ?", username).first
        end
    end

    def friends_list()
        hash_list = self.db.execute("SELECT friends_id FROM friends WHERE user_id = ?", @id)
        list = []
        hash_list.each do |hash|
            list << Friend.new(hash['friends_id'])
        end
        return list
    end

    def messages(id)
        hash_list = self.db.execute("SELECT id FROM messages WHERE reciever_id = ? OR sender_id = ?", @id, @id)
        list = []
        hash_list.each do |hash|
            list << Message.new(hash['friends_id'])
        end
        return list
    end
    
    def self.id_by_username(username)
        db.execute("SELECT id FROM users WHERE username = ?", username)
    end

    def self.add(params)
        db.execute("INSERT INTO users (username, password_hash, sign_up_date, admin, geotag) VALUES(?,?,?,?,?)", params['username'], BCrypt::Password.create(params['plaintext']), "#{Time.now}", 0, params['geotag'])
    end
    
end