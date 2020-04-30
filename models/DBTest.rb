class DBTest < DBEntity

    def self.connection
        begin 
            SQLQuery.new.get(['*'], 'users').send
        rescue 
            return false
        end
        return true
    end
    
end