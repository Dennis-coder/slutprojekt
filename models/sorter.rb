class Sorter

    def message_compare(message1, message2)
        message1['timestamp'].each_char.with_index do |message, index|
            if message > message2['timestamp'][index]
                return message1
            elsif message < message2['timestamp'][index]
                return message2
            end
        end
        return message1
    end

    def timestamp_compare(time1, time2)
        time1.each_char.with_index do |time, index|
            if time > time2[index]
                return time1
            elsif time < time2[index]
                return time2
            end
        end
    end

    def timestamp_sort(list)
        temp = list.dup
        out = []
        while temp.length > 0
            latest_index = 0
            temp.each_with_index do |item, index|
                if temp[latest_index] != Sorter.message_compare(temp[latest_index], item)
                    latest_index = index
                end
            end
            out << temp[latest_index]
            temp.delete_at(latest_index)
        end
        return out
    end

    def messages(list1, list2)
        list1 = Sorter.timestamp_sort(list1)
        list2 = Sorter.timestamp_sort(list2)
        messages = []
        while list1.length > 0 && list2.length > 0
            message = Sorter.message_compare(list1.first, list2.first)
            messages << message
            if message == list1.first
                list1.delete_at(0)
            else
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

end