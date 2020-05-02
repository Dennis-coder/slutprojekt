class Report < DBEntity

    attr_accessor :id, :accuser, :accused, :reason

    def initialize()
        @accuser = nil
        @accused = nil
        @reason = nil
    end
    
    def send()
        SQLQuery.new.add('reports', ['accused', 'accuser', 'reason'], [@accused, @accuser, @reason]).send
    end

    def self.get(id)
        report = Report.new()
        properties = SQLQuery.new.get('reports', ['*']).where.if('id', id).send.first
        report.id = properties['id']
        report.accuser = properties['accuser']
        report.accused = properties['accused']
        report.reason = properties['reason']

        return report
    end

    def self.get_all
        hash_list = SQLQuery.new.get('reports', ['id']).send
        list = []
        hash_list.each do |hash|
            list << Report.get(hash['id'])
        end
        return list
    end

    def self.delete(id)
        SQLQuery.new.del('reports').where.if('id', id).send
    end

end