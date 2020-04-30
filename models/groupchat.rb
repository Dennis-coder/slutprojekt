class Groupchat < DBEntity

    attr_accessor :id, :name, :last_interaction, :messages, :users

    def initialize()
        @name = nil
        @users = nil
    end
    
    def add()
        db.execute("INSERT INTO groups (name, last_interaction) VALUES(?,?)", @name, "#{Time.now}")
        id = db.execute("SELECT id FROM groups").last['id']
        @users.each do |user|
            Groupchat.add_user(user.last, id)
        end
        return id
    end

    def get_messages()
        hash_list = db.execute("SELECT * FROM groups_messages WHERE group_id = ?", @id)
        list = []
        hash_list.each do |hash|
            list << Message.get(hash['id'], 'group')
        end
        return list
    end

    def get_users()
        hash_list = db.execute("SELECT user_id FROM groups_handler WHERE group_id = ?", @id)
        list = []
        hash_list.each do |hash|
            list << User.get(hash['user_id'])
        end
        return list
    end

    def self.get(id)
        groupchat = Groupchat.new()
        properties = db.execute("SELECT * FROM groups WHERE id = ?", id).first
        groupchat.id = properties['id']
        groupchat.name = properties['name']
        groupchat.last_interaction = properties['last_interaction']
        groupchat.messages = groupchat.get_messages()
        groupchat.users = groupchat.get_users()

        return groupchat
    end

    def self.add_user(user_id, group_id)
        db.execute("INSERT INTO groups_handler (group_id, user_id) VALUES(?,?)", group_id, user_id)
    end

    def self.new_messages(user_id, params)
        group = Groupchat.get(params['group_id'].to_i)
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