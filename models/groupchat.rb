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
        db.execute("INSERT INTO groups (name, created_at, last_interaction) VALUES(?,?,?)", name, "#{Time.now.utc}", "#{Time.now.utc}")
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
        db.execute("INSERT INTO groups_messages (text, timestamp, sender_id, group_id) VALUES(?,?,?,?)", params['message'], "#{Time.now.utc}", user.id, params['group_id'])
        
        db.execute("UPDATE groups SET last_interaction = ? WHERE id = ?", "#{Time.now.utc}", params['group_id'])
    end

    def messages()
        db.execute("SELECT * FROM groups_messages WHERE group_id = ?", @id).reverse
    end

end