class Message < DBEntity

    attr_accessor :id, :text, :reciever_id, :sender_id, :timestamp

    def initialize(id, type)
        if type == 'friend'
            properties = db.execute('SELECT id,text,reciever_id,sender_id,timestamp FROM messages WHERE id = ?', id).first
            @reciever_id = properties['reciever_id']
        else
            properties = db.execute('SELECT id,text,group_id,sender_id,timestamp FROM groups_messages WHERE id = ?', id).first
            @group_id = properties['group_id']
        end
        @id = properties['id']
        @text = properties['text']
        @sender_id = properties['sender_id']
        @timestamp = properties['timestamp']
    end

end