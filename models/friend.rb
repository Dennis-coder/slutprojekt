class Friend < DBEntity

    attr_accessor :id, :username, :last_interaction, :friends_since, :messages

    def initialize(user_id, friend_id)
        properties = self.properties(user_id, friend_id)
        @id = properties['id']
        @username = properties['username']
        @last_interaction = properties['last_interaction']
        @friends_since = properties['friends_since']
        @messages = get_messages(user_id)
    end

    def properties(user_id, friend_id)
        self.db.execute("SELECT id, username FROM users WHERE id = ?", friend_id).first.merge(self.db.execute("SELECT last_interaction, friends_since FROM friends WHERE (user_id = ? AND user2_id = ?) OR (user2_id = ? AND user_id = ?)", user_id, friend_id, user_id, friend_id).first)
    end

    def get_messages(user_id)
        hash_list = db.execute("SELECT id FROM messages WHERE (reciever_id = ? AND sender_id = ?) OR (reciever_id = ? AND sender_id = ?) ORDER BY timestamp", user_id, @id, @id, user_id)
        list = []
        hash_list.each do |hash|
            list << Message.new(hash['id'], 'friend')
        end
        return list
    end

    def self.send_message(params, user)
        db.execute("INSERT INTO messages (text, timestamp, sender_id, reciever_id) VALUES(?,?,?,?)", params['message'], "#{Time.now}", user.id, params['reciever'])
        
        db.execute("UPDATE friends SET last_interaction = ? WHERE id = ?", "#{Time.now}", Friend.relation_id(user.id, params['reciever']))
    end

    def self.conversation(id1, id2)
        recieved = Message.messages(id1, id2)
        sent = Message.messages(id2, id1)
        messages = Sorter.messages(recieved, sent)
        return messages
    end

    def self.send_request(user_id, user2_id)
        db.execute("INSERT INTO friends (user_id, user2_id, status, last_interaction, friends_since) VALUES(?,?,?,?,?)", user_id, user2_id, 1, "#{Time.now}", "")
    end

    def self.accept_request(user_id, user2_id)
        db.execute("UPDATE friends SET status = ?, last_interaction = ?, friends_since = ? WHERE id = ?", 0, "#{Time.now}", "#{Time.now}", Friend.relation_id(user_id, user2_id))
    end

    def self.pending_requests(id)
        temp = db.execute("SELECT user_id FROM friends WHERE user2_id = ? AND status = ?", id, 1)
        out = []
        temp.each do |id|
            out << User.new(id['user_id'])
        end
        return out
    end

    def self.sender(user_id, user2_id)
        temp = db.execute("SELECT user_id FROM friends WHERE user_id = ? AND user2_id = ? AND status = ?", user_id, user2_id, 1).first
        if temp != nil
            if temp['user_id'] == user_id
                return user_id
            else
                return user2_id
            end
        end
        temp = db.execute("SELECT user_id FROM friends WHERE user_id = ? AND user2_id = ? AND status = ?", user2_id, user_id, 1).first
        if temp != nil
            if temp['user_id'] == user_id
                return user_id
            else
                return user2_id
            end
        end
        return nil
    end

    def self.delete(user_id, user2_id)
        db.execute("DELETE FROM friends WHERE id = ?", Friend.relation_id(user_id, user2_id))
    end

    def self.status?(user_id, user2_id)
        temp = db.execute("SELECT status FROM friends WHERE user_id = ? AND user2_id = ?", user_id, user2_id).first
        if temp != nil
            if temp['status'] == 0
                return "friends"
            elsif temp['status'] == 1
                return "pending"
            end
        end
        temp = db.execute("SELECT status FROM friends WHERE user_id = ? AND user2_id = ?", user2_id, user_id).first
        if temp != nil
            if temp['status'] == 0
                return "friends"
            elsif temp['status'] == 1
                return "pending"
            end
        end
        return nil
    end

    def self.relation_id(user_id, user2_id)
        temp = db.execute("SELECT id FROM friends WHERE user_id = ? AND user2_id = ?", user_id, user2_id).first
        if temp != nil
            return temp['id']
        end
        temp = db.execute("SELECT id FROM friends WHERE user_id = ? AND user2_id = ?", user2_id, user_id).first
        if temp != nil
            return temp['id']
        end
        return nil
    end

    def self.new_messages(user_id, params)
        friend = Friend.new(user_id, params['id'].to_i)
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