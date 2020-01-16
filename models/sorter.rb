class Sorter

    def self.timestamp_compare(time1, time2)
        time1.each_char.with_index do |time, index|
            if time > time2[index]
                return true
            elsif time < time2[index]
                return false
            end
        end
        return true
    end

    def self.last_interaction(list)
        temp = list.dup
        out = []
        while temp.length > 0
            latest_index = 0
            temp.each_with_index do |item, index|
                if Sorter.timestamp_compare(temp[latest_index].last_interaction, item.last_interaction) == false
                    latest_index = index
                end
            end
            out << temp[latest_index]
            temp.delete_at(latest_index)
        end
        return out
    end

    def self.messages(list1, list2)
        messages = []
        while list1.length > 0 && list2.length > 0
            if Sorter.timestamp_compare(list1.first.timestamp, list2.first.timestamp) == true
                messages << list1.first
                list1.delete_at(0)
            else
                messages << list2.first
                list2.delete_at(0)
            end
        end
        if list1.length > 0
            list1.each do |message|
                messages << message
            end
        elsif list2.length > 0
            list2.each do |message|
                messages << message
            end
        end
        return messages
    end

    def self.friendslist(list)
        temp = list.dup
        out = []
        while temp.length > 0
            latest_index = 0
            temp.each_with_index do |item, index|
                if Sorter.timestamp_compare(temp[latest_index].last_interaction, item.last_interaction) == false
                    latest_index = index
                end
            end
            out << temp[latest_index]
            temp.delete_at(latest_index)
        end
        return out
    end

    def self.search(users)
        out = users

        return out
    end

end