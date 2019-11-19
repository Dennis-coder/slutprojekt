def timestamp_compare(time1, time2)

    time1.split
    time2.split

    time1.each_with_index do |time, index|
        if time > time2[index]

        elsif time < time2[index]

        end
    end

end

def sort_by_interaction

    timestamp_compare(self[1][:last_interaction], self[2][:last_interaction])

end