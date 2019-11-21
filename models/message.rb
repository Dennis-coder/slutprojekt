class Message < DBEntity

    def self.messages(sender_id, reciever_id)
        db.execute("SELECT id, text, timestamp FROM messages WHERE reciever_id = ? AND sender_id = ?", sender_id, reciever_id)
    end

    def self.add
        db.execute("INSERT INTO messages (text, image, timestamp, geotag, status, sender_id, reciever_id) VALUES(?,?,?,?,?,?,?)")
    end

end