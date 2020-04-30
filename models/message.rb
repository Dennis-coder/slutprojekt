class Message < DBEntity

    attr_accessor :id, :text, :reciever_id, :sender_id, :timestamp, :type, :group_id

    def initialize()
        @text = nil
        @sender_id = nil
        @reciever_id = nil
        @group_id = nil
        @type == nil
    end

    def send()
        if @type == 'friend'
            db.execute("INSERT INTO messages (text, timestamp, sender_id, reciever_id) VALUES(?,?,?,?)", @text, "#{Time.now}", @sender_id, @reciever_id)
        
            db.execute("UPDATE friends SET last_interaction = ? WHERE id = ?", "#{Time.now}", Friend.relation_id(@sender_id, @reciever_id))
        else
            db.execute("INSERT INTO groups_messages (text, timestamp, sender_id, group_id) VALUES(?,?,?,?)", @text, "#{Time.now}", @sender_id, @group_id)
            
            db.execute("UPDATE groups SET last_interaction = ? WHERE id = ?", "#{Time.now}", @group_id)
        end
    end

    def self.get(id, type)
        msg = Message.new()
        if type == 'friend'
            properties = db.execute('SELECT id,text,reciever_id,sender_id,timestamp FROM messages WHERE id = ?', id).first
            msg.reciever_id = properties['reciever_id']
        else
            properties = db.execute('SELECT id,text,group_id,sender_id,timestamp FROM groups_messages WHERE id = ?', id).first
            msg.group_id = properties['group_id']
        end
        msg.id = properties['id']
        msg.text = properties['text']
        msg.sender_id = properties['sender_id']
        msg.timestamp = properties['timestamp']

        return msg
    end

end