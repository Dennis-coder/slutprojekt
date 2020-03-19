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
        out = Array.new(list.length) {nil}
        out.each_with_index do |_, index|
            latest_index = 0
            temp.each_with_index do |item, index2|
                if Sorter.timestamp_compare(item.last_interaction, temp[latest_index].last_interaction) == true
                    latest_index = index2
                end
            end
            out[index] = temp[latest_index].dup
            temp.delete_at(latest_index)
        end
        return out
    end

    def self.messages(list1, list2)
        messages = Array.new(list1.length + list2.length) {nil}
        messages.each_with_index do |_, index|
            if list1.length == 0
                messages[index] = list2.first
                list2.delete_at(0)
            elsif list2.length == 0
                messages[index] = list1.first
                list1.delete_at(0)
            else
                if Sorter.timestamp_compare(list1.first.timestamp, list2.first.timestamp) == true
                    messages[index] =list1.first
                    list1.delete_at(0)
                else
                    messages[index] = list2.first
                    list2.delete_at(0)
                end
            end
        end
        return messages
    end

    def self.alphabetical(list)
        temp = list.dup
        out = Array.new(list.length) {nil}
        out.each_with_index do |_, pos|
            i = 0
            temp.each_with_index do |user, index|
                temp_list = [user.username.downcase, temp[i].username.downcase]
                if temp_list.sort[0] = user.username.downcase
                    i = index
                end
            end
            out[pos] = temp[i]
            temp.delete_at(i)
        end
        return out.reverse
    end

    def self.search(users)
        out = users

        return out
    end

end