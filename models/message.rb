class Message < DBEntity

    def self.messages(sender_id, reciever_id)
        db.execute("SELECT id, text, timestamp, sender_id FROM messages WHERE reciever_id = ? AND sender_id = ?", sender_id, reciever_id)
    end

    def self.send(text, geotag, sender_id, reciever_id)
        db.execute("INSERT INTO messages (text, image, timestamp, geotag, status, sender_id, reciever_id) VALUES(?,?,?,?,?,?,?)", text, "", "#{Time.now.utc}", geotag, 1, sender_id, reciever_id)
    end

end