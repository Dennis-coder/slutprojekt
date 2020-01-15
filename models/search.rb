class Search < DBEntity

    def self.partial_match(username, term)
        username.each_char.with_index do |char, index|
            if char == term[0]
                matched = 0
                term.each_char.with_index do |char, index2|
                    if username[index + index2] == term[index2]
                        matched += 1
                    end
                end
                if matched == term.length
                    return true
                end
            end
        end
        return false
    end

    def self.find_friends(term)
        user_ids = User.all
        users = []
        user_ids.each do |id|
            users << User.new(id['id'])
        end
        out = []
        users.each do |user|
            if Search.partial_match(user.username.downcase, term.downcase) == true
                out << user
            end
        end
        return Sorter.search(out)
    end

end