class Debug
    def self.put(obj)
        p ""
        p obj
        p ""
    end

    def self.array(list)
        p ""
        list.each do |item|
            p item
            p ""
        end
    end

    def self.title(title, obj)
        p ""
        p title
        p ""
        p obj
        p ""
    end
end