class Message < DBEntity

    attr_accessor :id, :text, :reciever_id, :sender_id, :timestamp

    def initialize(id)
        properties = self.properties(id)
        if properties != nil
            @id = properties['id']
            @text = properties['text']
            @reciever_id = properties['reciever_id']
            @sender_id = properties['sender_id']
            @timestamp = properties['timestamp']
        end
    end

    def properties(id)
        db.execute('SELECT id,text,reciever_id,sender_id,timestamp FROM messages WHERE id = ?', id).first
    end

    def self.send(params, user)
        db.execute("INSERT INTO messages (text, image, timestamp, status, sender_id, reciever_id) VALUES(?,?,?,?,?,?)", params['message'], "", "#{Time.now.utc}", 1, user.id, User.just_id(params['reciever']))
        db.execute("UPDATE friends SET last_interaction = ? WHERE id = ?", "#{Time.now.utc}", Friend.relation_id(user.id, User.just_id(params['reciever'])))
    end

    def self.messages(id1, id2)
        hash_list = db.execute("SELECT id FROM messages WHERE reciever_id = ? AND sender_id = ? ORDER BY timestamp", id1, id2)
        list = []
        hash_list.each do |hash|
            list << Message.new(hash['id'])
        end
        return list.reverse
    end

    def self.conversation(id1, id2)
        recieved = self.messages(id1, id2)
        sent = self.messages(id2, id1)
        messages = Sorter.messages(recieved, sent)
        return messages
    end

    def self.new_messages(id1, params)
        id2 = params['id']
        latest = params['latest']
        messages = Message.conversation(id1, id2)
        newMessages = []
        messages.each do |message|
            if !Sorter.timestamp_compare(latest, message.timestamp)
                newMessages << message
            end
        end
        return newMessages
    end
end