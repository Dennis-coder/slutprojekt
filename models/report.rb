class Report < DBEntity

    attr_accessor :id, :accuser, :accused, :reason

    def initialize()
        @accuser = nil
        @accused = nil
        @reason = nil
    end
    
    def send()
        db.execute("INSERT INTO reports (accused, accuser, reason) VALUES(?,?,?)", @accused, @accuser, @reason)
    end

    def self.get(id)
        report = Report.new()
        properties = db.execute("SELECT * FROM reports WHERE id = ?", id).first
        report.id = properties['id']
        report.accuser = properties['accuser']
        report.accused = properties['accused']
        report.reason = properties['reason']

        return report
    end

    def self.get_all
        hash_list = db.execute("SELECT id FROM reports")
        list = []
        hash_list.each do |hash|
            list << Report.get(hash['id'])
        end
        return list
    end

    def self.delete(id)
        db.execute("DELETE FROM reports WHERE id = ?", id)
    end

end