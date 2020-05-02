class User < DBEntity

    attr_accessor :id, :username, :password_hash, :admin
    
    def initialize()
        @id = nil
        @username = nil
        @password_hash = nil
        @admin = nil
    end
    
    def add()
        SQLQuery.new.add('users', ['username', 'password_hash', 'admin'], [@username, @password_hash, 0]).send
    end
    
    def friendslist()
        hash_list = SQLQuery.new.get('friends', ['user_id', 'user2_id']).where.open_.if('user_id', @id).or.if('user2_id', @id).close_.and.if('status', 0).send
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
        id_list = SQLQuery.new.get('groups_handler', ['group_id']).where.if('user_id', @id).send
        groups_list = []
        id_list.each do |id|
            groups_list << Groupchat.get(id['group_id'])
        end
        return Sorter.last_interaction(groups_list)
    end

    def messages(id)
        hash_list = SQLQuery.new.get('messages', ['id']).where.if('reciever_id', @id).or.if('sender_id', @id).send
        hash_list.each do |hash|
            list << Message.get(hash['friends_id'])
        end
        return list
    end

    def self.get(id)
        user = User.new()
        properties = SQLQuery.new.get('users', ['*']).where.if('id', id).send.first
        user.id = properties['id']
        user.username = properties['username']
        user.password_hash = properties['password_hash']
        user.admin = properties['admin']

        return user
    end

    def self.id(username)
        SQLQuery.new.get('users', ['id']).where.if('username', username).send.first['id']
    end

    def self.username(id)
        SQLQuery.new.get('users', ['username']).where.if('id', id).send.first['username']
    end

    def self.all
        SQLQuery.new.get('users', ['id']).send
    end

    def self.change_password(id, password)
        SQLQuery.new.update('users', ['password_hash'], [BCrypt::Password.create(password)]).where.if('id', id).send
    end

    def self.delete(id)
        SQLQuery.new.update('users', ['username', 'password_hash'], ['Deleted user', 'Deleted user']).where.if('id', id).send
        SQLQuery.new.del('reports').where.if('accused', id).send
    end
    
end