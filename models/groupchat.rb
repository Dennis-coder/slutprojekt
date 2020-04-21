class Groupchat < DBEntity

    attr_reader :id, :name, :last_interaction, :created_at, :messages

    def initialize(id)
        properties = db.execute("SELECT * FROM groups WHERE id = ?", id).first
        @id = properties['id']
        @name = properties['name']
        @created_at = properties['created_at']
        @last_interaction = properties['last_interaction']
        @messages = self.messages()
    end

    def self.create(list)
        name = list.first.last
        list.delete('group_name')
        db.execute("INSERT INTO groups (name, created_at, last_interaction) VALUES(?,?,?)", name, "#{Time.now}", "#{Time.now}")
        id = db.execute("SELECT id FROM groups").last['id']
        list.each do |user|
            Groupchat.add_user(user.last, id)
        end
        return id
    end

    def self.add_user(user_id, group_id)
        db.execute("INSERT INTO groups_handler (group_id, user_id) VALUES(?,?)", group_id, user_id)
    end

    def self.send_message(params, user)
        db.execute("INSERT INTO groups_messages (text, timestamp, sender_id, group_id) VALUES(?,?,?,?)", params['message'], "#{Time.now}", user.id, params['group_id'])
        
        db.execute("UPDATE groups SET last_interaction = ? WHERE id = ?", "#{Time.now}", params['group_id'])
    end

    def messages()
        hash_list = db.execute("SELECT * FROM groups_messages WHERE group_id = ?", @id)
        list = []
        hash_list.each do |hash|
            list << Message.new(hash['id'], 'group')
        end
        return list
    end

    def self.new_messages(user_id, params)
        group = Groupchat.new(params['group_id'].to_i)
        latest = params['latest']
        newMessages = []
        group.messages.each do |message|
            if !Sorter.timestamp_compare(latest, message.timestamp) && message.sender_id != user_id
                newMessages << {'text' => message.text, 'timestamp' => message.timestamp, 'sender' => User.username(message.sender_id)}
            end
        end
        return newMessages
    end

end