class SQLQuery < DBEntity

    attr_accessor :query, :values

    def initialize
        @query = ''
        @values = []
    end

    def insert(table, columns, values)
        @query += "INSERT INTO " + table + ' ('
        columns.each do |column|
            @query += column + ','
        end
        @query[@query.length-1] = ''
        @query += ') VALUES(' + '?,' * columns.length
        @query[@query.length-1] = ''
        @query += ') '
        values.each do |values|
            @values << values
        end
        return self
    end

    def get(columns, table)
        @query += "SELECT "
        columns.each do |column|
            @query += column + ','
        end
        @query[@query.length-1] = ''
        @query += " FROM " + table + ' '
        return self
    end

    def delete(table)
        @query += 'DELETE FROM ' + table + ' '
        return self
    end

    def update(table, columns, values)
        @query += 'UPDATE ' + table + ' SET'
        columns.each do |column|
            @query += ' ' + column + ' = ?,'
        end
        @query[@query.length-1] = ' '
        values.each do |values|
            @values << values
        end
        return self
    end

    def <
        @query += '( '
        return self
    end

    def >
        @query += ') '
        return self
    end

    def where(column, value)
        @query += 'WHERE ' + column + ' = ? '
        @values << value
        return self
    end

    def and
        @query += 'AND '
        return self
    end

    def or
        @query += 'OR '
        return self
    end

    def send
        db.execute(@query, @values)
    end

end