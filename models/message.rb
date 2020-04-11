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
end