class Message < DBEntity

    def self.messages(sender_id, reciever_id)
        db.execute("SELECT id, text, timestamp, sender_id FROM messages WHERE reciever_id = ? AND sender_id = ?", sender_id, reciever_id)
    end

    def self.send(text, geotag, sender_id, reciever_id)
        db.execute("INSERT INTO messages (text, image, timestamp, geotag, status, sender_id, reciever_id) VALUES(?,?,?,?,?,?,?)", text, "", "#{Time.now.utc}", geotag, 1, sender_id, reciever_id)
    end

    def self.sender_by_id(id)
        db.execute("SELECT sender_id FROM messages WHERE id = ?", id)
    end

    def self.conversation(id1, id2)
        recieved = Message.messages(id1, id2)
		sent = Message.messages(id2, id1)
        messages = Sorter.messages(recieved, sent)
        return messages
    end

    def self.new_messages(id1, id2, latest)
        messages = Message.conversation(id1, id2)
        newMessages = []
        messages.each do |message| 
            if Sorter.timestamp_compare(latest, message[2]) != latest
                newMessages << message
            else
                break
            end
        end
        return newMessages
    end
end