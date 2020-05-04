class Message

    attr_accessor :id, :text, :reciever_id, :sender_id, :timestamp, :type, :group_id

    def initialize()
        @text = nil
        @sender_id = nil
        @reciever_id = nil
        @group_id = nil
        @type == nil
    end

    # Stores a message in the database.
    def send()
        if @type == 'friend'
            SQLQuery.new.add('messages',['text','timestamp','sender_id','reciever_id'],[@text, Time.now.to_s, @sender_id, @reciever_id]).send

            SQLQuery.new.update('friends', ['last_interaction'], [Time.now.to_s]).where.if('id', Friend.relation_id(@sender_id, @reciever_id)).send
        else
            SQLQuery.new.add('groups_messages',['text','timestamp','sender_id','group_id'],[@text, Time.now.to_s, @sender_id, @group_id]).send

            SQLQuery.new.update('groups', ['last_interaction'], [Time.now.to_s]).where.if('id', @group_id).send
        end
    end

    # Get a message.
    # 
    # id - The message id.
    # type - The message type, friend or group.
    # 
    # Returns the message.
    def self.get(id, type)
        msg = Message.new()
        if type == 'friend'
            properties = SQLQuery.new.get('messages', ['id', 'text', 'reciever_id', 'sender_id', 'timestamp']).where.if('id', id).send.first
            msg.reciever_id = properties['reciever_id']
        else
            properties = SQLQuery.new.get('groups_messages', ['id', 'text', 'group_id', 'sender_id', 'timestamp']).where.if('id', id).send.first
            msg.group_id = properties['group_id']
        end
        msg.id = properties['id']
        msg.text = properties['text']
        msg.sender_id = properties['sender_id']
        msg.timestamp = properties['timestamp']

        return msg
    end

end