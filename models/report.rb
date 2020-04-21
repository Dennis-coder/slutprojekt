class Report < DBEntity

    attr_accessor :id, :accuser, :accused, :reason

    def initialize(id)
        properties = db.execute("SELECT * FROM reports WHERE id = ?", id).first
        @id = properties['id']
        @accuser = properties['accuser']
        @accused = properties['accused']
        @reason = properties['reason']
    end

    def self.send(user_id, params)
        db.execute("INSERT INTO reports (accused, accuser, reason) VALUES(?,?,?)", User.id(params['username']), user_id, params['reason'])
    end

    def self.get_all
        hash_list = db.execute("SELECT id FROM reports")
        list = []
        hash_list.each do |hash|
            list << Report.new(hash['id'])
        end
        return list
    end

    def self.delete(id)
        db.execute("DELETE FROM reports WHERE id = ?", id)
    end

end