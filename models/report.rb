# The class that handles all report functions.
class Report

    attr_accessor :id, :accuser, :accused, :reason

    def initialize()
        @accuser = nil
        @accused = nil
        @reason = nil
    end
    
    # Stores a report in the database
    def send()
        SQLQuery.new.add('reports', ['accused', 'accuser', 'reason'], [@accused, @accuser, @reason]).send
    end

    # Get a report.
    # 
    # id - The report id.
    # 
    # Returns the report.
    def self.get(id)
        report = Report.new()
        properties = SQLQuery.new.get('reports', ['*']).where.if('id', id).send.first
        report.id = properties['id']
        report.accuser = properties['accuser']
        report.accused = properties['accused']
        report.reason = properties['reason']

        return report
    end

    # Gets all reports.
    # 
    # hash_list - list with all the ids.
    # 
    # Returns a list with all report ids.
    def self.get_all
        hash_list = SQLQuery.new.get('reports', ['id']).send
        list = []
        hash_list.each do |hash|
            list << Report.get(hash['id'])
        end
        return list
    end

    # Deletes a report.
    # 
    # id - The report id.
    def self.delete(id)
        SQLQuery.new.del('reports').where.if('id', id).send
    end

end