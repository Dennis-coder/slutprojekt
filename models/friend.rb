# The class that handles all friend functions.
class Friend

    attr_accessor :id, :username, :last_interaction, :messages

    def initialize()
        @id = nil
        @username = nil
        @last_interaction = nil
        @messages = nil
    end

    # Gets messages sent to and from the friend.
    # 
    # user_id - Your user id.
    # hash_list - A hash list with the message ids.
    # 
    # Returns messages.
    def get_messages(user_id)
        hash_list = SQLQuery.new.get('messages', ['id']).where.open_.if('reciever_id', user_id).and.if('sender_id', @id).close_.or.open_.if('reciever_id', @id).and.if('sender_id', user_id).close_.order('timestamp').send
        list = []
        hash_list.each do |hash|
            list << Message.get(hash['id'], 'friend')
        end
        return list
    end

    # Get a friend.
    # 
    # user_id - Your user id.
    # friend_id - The user id of the friend.
    # 
    # Returns the friend.
    def self.get(user_id, friend_id)
        friend = Friend.new()
        properties = SQLQuery.new.get('users', ['users.id', 'username', 'last_interaction', 'user_id', 'user2_id']).join('friends').where.open_.open_.if('user_id', user_id).and.if('user2_id', friend_id).close_.or.open_.if('user2_id', user_id).and.if('user_id', friend_id).close_.close_.and.if('users.id', friend_id).send.first
        friend.id = properties['id']
        friend.username = properties['username']
        friend.last_interaction = properties['last_interaction']
        friend.messages = friend.get_messages(user_id)

        return friend
    end

    # Send a frind request.
    # 
    # user_id - The id of user 1.
    # user2_id - The id of user 2.
    def self.send_request(user_id, user2_id)
        SQLQuery.new.add('friends', ['user_id', 'user2_id', 'status', 'last_interaction'], [user_id, user2_id, 1, Time.now.to_s]).send
    end

    # Accept a frind request.
    # 
    # user_id - The id of user 1.
    # user2_id - The id of user 2.
    def self.accept_request(user_id, user2_id)
        SQLQuery.new.update('friends', ['status', 'last_interaction'], [0, Time.now.to_s]).where.if('id', Friend.relation_id(user_id, user2_id)).send
    end

    # Gets users with a pending friend request sent to you.
    # 
    # id - Your user id.
    # 
    # Returns list of users.
    def self.pending_requests(id)
        temp = SQLQuery.new.get('friends', ['user_id']).where.if('user2_id', id).and.if('status', 1).send
        out = []
        temp.each do |id|
            out << User.get(id['user_id'])
        end
        return out
    end

    # Gets the sender of a friend request.
    # 
    # user_id - The id of user 1.
    # user2_id - The id of user 2.
    # 
    # Returns the id or nil.
    def self.sender(user_id, user2_id)
        temp = SQLQuery.new.get('friends', ['user_id']).where.open_.open_.if('user_id', user_id).and.if('user2_id', user2_id).close_.or.open_.if('user_id', user2_id).and.if('user2_id', user_id).close_.close_.and.if('status', 1).send.first
        if temp != nil
            if temp['user_id'] == user_id
                return user_id
            else
                return user2_id
            end
        end
        return nil
    end

    # Deletes a friendship relation.
    # 
    # user_id - The id of user 1.
    # user2_id - The id of user 2.
    def self.delete(user_id, user2_id)
        SQLQuery.new.del('friends').where.if('id', Friend.relation_id(user_id, user2_id)).send
    end

    # Gets the status of a friendship relation.
    # 
    # user_id - The id of user 1.
    # user2_id - The id of user 2.
    # 
    # Returns the status or nil.
    def self.status?(user_id, user2_id)
        temp = SQLQuery.new.get('friends', ['status']).where.open_.if('user_id', user_id).and.if('user2_id', user2_id).close_.or.open_.if('user_id', user2_id).and.if('user2_id', user_id).close_.send.first
        if temp != nil
            if temp['status'] == 0
                return "friends"
            elsif temp['status'] == 1
                return "pending"
            end
        end
        return nil
    end

    # Get the friendship relation id.
    # 
    # user_id - The id of user 1.
    # user2_id - The id of user 2.
    # 
    # Returns the id or nil.
    def self.relation_id(user_id, user2_id)
        temp = SQLQuery.new.get('friends', ['id']).where.open_.if('user_id', user_id).and.if('user2_id', user2_id).close_.or.open_.if('user_id', user2_id).and.if('user2_id', user_id).close_.send.first
        if temp != nil
            return temp['id']
        end
        return nil
    end

    # Get new messages.
    # 
    # user_id - Your user id.
    # params - Includes friend id and timestamp of last check.
    # 
    # Returns the new messages.
    def self.new_messages(user_id, params)
        friend = Friend.get(user_id, params['id'].to_i)
        latest = params['latest']
        newMessages = []
        friend.messages.each do |message|
            if !Sorter.timestamp_compare(latest, message.timestamp) && message.sender_id != user_id
                newMessages << {'text' => message.text, 'timestamp' => message.timestamp, 'sender' => User.username(message.sender_id)}
            end
        end
        return newMessages
    end

end