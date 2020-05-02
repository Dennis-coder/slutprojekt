class Groupchat < DBEntity

    attr_accessor :id, :name, :last_interaction, :messages, :users

    def initialize()
        @name = nil
        @users = nil
    end
    
    def add()
        SQLQuery.new.add('groups', ['name', 'last_interaction'], [@name, Time.now.to_s]).send
        id = SQLQuery.new.get('groups', ['id']).send.last['id']
        @users.each do |user|
            Groupchat.add_user(user.last, id)
        end
        return id
    end

    def get_messages()
        hash_list = SQLQuery.new.get('groups_messages', ['*']).where.if('group_id', @id).send
        list = []
        hash_list.each do |hash|
            list << Message.get(hash['id'], 'group')
        end
        return list
    end

    def get_users()
        hash_list = SQLQuery.new.get('groups_handler', ['user_id']).where.if('group_id', @id).send
        list = []
        hash_list.each do |hash|
            list << User.get(hash['user_id'])
        end
        return list
    end

    def self.get(id)
        groupchat = Groupchat.new()
        properties = SQLQuery.new.get('groups', ['*']).where.if('id', id).send.first
        groupchat.id = properties['id']
        groupchat.name = properties['name']
        groupchat.last_interaction = properties['last_interaction']
        groupchat.messages = groupchat.get_messages()
        groupchat.users = groupchat.get_users()

        return groupchat
    end

    def self.add_user(user_id, group_id)
        SQLQuery.new.add('groups_handler', ['group_id', 'user_id'], [group_id, user_id]).send
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