# The class that handles all groupchat functions.
class Groupchat

    attr_accessor :id, :name, :last_interaction, :messages, :users

    def initialize()
        @name = nil
        @users = nil
    end
    
    # ADd a group.
    # 
    # Returns the group id.
    def add()
        SQLQuery.new.add('groups', ['name', 'last_interaction'], [@name, Time.now.to_s]).send
        id = SQLQuery.new.get('groups', ['id']).send.last['id']
        @users.each do |user|
            Groupchat.add_user(user.last, id)
        end
        return id
    end

    # Get the messages for a group.
    # 
    # hash_list - The group message ids.
    # 
    # Returns the messages.
    def get_messages()
        hash_list = SQLQuery.new.get('groups_messages', ['*']).where.if('group_id', @id).send
        list = []
        hash_list.each do |hash|
            list << Message.get(hash['id'], 'group')
        end
        return list
    end

    # Get a group.
    # 
    # id - The group id.
    # 
    # Returns the group.
    def self.get(id)
        groupchat = Groupchat.new()
        properties = SQLQuery.new.get('groups', ['*']).where.if('id', id).send.first
        groupchat.id = properties['id']
        groupchat.name = properties['name']
        groupchat.last_interaction = properties['last_interaction']
        groupchat.messages = groupchat.get_messages()

        return groupchat
    end

    # Adds a user to the groupchat.
    # 
    # user_id - Your user id.
    # group_id - The group id.
    def self.add_user(user_id, group_id)
        SQLQuery.new.add('groups_handler', ['group_id', 'user_id'], [group_id, user_id]).send
    end

    # Gets all new messages from the groupchat.
    # 
    # user_id - Your user id.
    # params - Includes group id and timestamp of last check.
    # 
    # Returns the new messages.
    def self.new_messages(user_id, params)
        group = Groupchat.get(params['id'].to_i)
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