# The class that handles the database tests.
class DBTest

    # Tests the connection to the database.
    # 
    # Returns true or false.
    def self.connection
        begin 
            SQLQuery.new.get('users',['*']).send
        rescue 
            return false
        end
        return true
    end
    
end