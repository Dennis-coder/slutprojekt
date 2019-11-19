class Message < DBEntity

    def self.messages(user_id)
        db.execute("SELECT * FROM messages WHERE (reciever_id, sender_id) VALUES(?,?) ", user_id, user_id)
    end

    def self.add
        db.execute("INSERT INTO messages (text, image, timestamp, geotag, status, sender_id, reciever_id) VALUES(?,?,?,?,?,?,?)")
    end

end