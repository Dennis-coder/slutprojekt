class Message < DBEntity

    def initialize(id1, id2)
        properties = self.properties(id1, id2)
        if properties != nil
            @id = properties['id']
            @text = properties['text']
            @reciever_id = properties['reciever_id']
            @sender_id = properties['sender_id']
            @timestamp = properties['timestamp']
        end
    end

    def self.send(text, geotag, sender_id, reciever_id)
        db.execute("INSERT INTO messages (text, image, timestamp, geotag, status, sender_id, reciever_id) VALUES(?,?,?,?,?,?,?)", text, "", "#{Time.now.utc}", geotag, 1, sender_id, reciever_id)
    end

    def self.messages(id1, id2)
        hash_list = db.execute("SELECT id FROM messages WHERE reciever_id = ? AND sender_id = ?", id1, id2)
        list = []
        hash_list.each do |hash|
            list << Message.new(hash['friends_id'])
        end
        return list
    end

    def self.conversation(id1, id2)
        recieved = self.messages(id1, id2)
		sent = self.messages(id2, id1)
        messages = Sorter.messages(recieved, sent)
        return messages
    end

    def self.new_messages(id1, id2, latest)
        messages = Message.conversation(id1, id2)
        newMessages = []
        messages.each do |message| 
            if Sorter.timestamp_compare(latest, message['timestamp']) != latest
                newMessages << message
            else
                break
            end
        end
        return newMessages
    end
end