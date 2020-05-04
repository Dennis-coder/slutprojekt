# The class that handles all user functions.
class User

    attr_accessor :id, :username, :password_hash, :admin
    
    def initialize()
        @id = nil
        @username = nil
        @password_hash = nil
        @admin = nil
    end
    
    # Adds a user.
    def add()
        SQLQuery.new.add('users', ['username', 'password_hash', 'admin'], [@username, @password_hash, 0]).send
    end
    
    # Gets the friends to a user.
    # 
    # hash_list - The list with the ids.
    # list - The list with the friends.
    # Sorter - The class that handles all sorting functions.
    # 
    # Returns a list with all friends.
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

    # Gets the groups a user is a part of.
    # 
    # id_list - The list of group ids.
    # groups_list - The list with the groups.
    # 
    # Returns a list with all groups.
    def groups()
        id_list = SQLQuery.new.get('groups_handler', ['group_id']).where.if('user_id', @id).send
        groups_list = []
        id_list.each do |id|
            groups_list << Groupchat.get(id['group_id'])
        end
        return Sorter.last_interaction(groups_list)
    end

    # Gets a user.
    # 
    # id - The id of the user we want.
    # User - The class that handles all user functions.
    # 
    # Returns the user.
    def self.get(id)
        user = User.new()
        properties = SQLQuery.new.get('users', ['*']).where.if('id', id).send.first
        user.id = properties['id']
        user.username = properties['username']
        user.password_hash = properties['password_hash']
        user.admin = properties['admin']

        return user
    end

    # Gets the id from the username.
    # 
    # username - The user username.
    # 
    # Returns the id.
    def self.id(username)
        SQLQuery.new.get('users', ['id']).where.if('username', username).send.first['id']
    end

    # Gets the username from the id.
    # 
    # id - The user id.
    # 
    # Returns the username.
    def self.username(id)
        SQLQuery.new.get('users', ['username']).where.if('id', id).send.first['username']
    end

    # Gets all user ids.
    # 
    # Returns the ids.
    def self.all
        SQLQuery.new.get('users', ['id']).send
    end

    # Changes password.
    # 
    # id - The id of the user.
    # password - The new password.
    def self.change_password(id, password)
        SQLQuery.new.update('users', ['password_hash'], [BCrypt::Password.create(password)]).where.if('id', id).send
    end

    # Deletes a user.
    # 
    # id - The id of the user to be deleted.
    def self.delete(id)
        SQLQuery.new.del('friends').where.if('user_id', id).or.if('user2_id', id).send
        SQLQuery.new.del('groups_handler').where.if('user_id', id).send
        SQLQuery.new.update('groups_messages', ['sender_id'], [0]).where.if('sender_id', id).send
        SQLQuery.new.del('messages').where.if('sender_id', id).or.if('reciever_id', id).send
        SQLQuery.new.del('reports').where.if('accused', id).send
        SQLQuery.new.del('users').where.if('id', id).send
    end
    
end