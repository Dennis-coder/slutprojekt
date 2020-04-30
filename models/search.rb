class Search

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

    def self.find_users(term, user_id)
        user_ids = User.all
        users = []
        user_ids.each do |id|
            users << User.get(id['id'])
        end
        out = []
        users.each do |user|
            if Search.partial_match(user.username.downcase, term.downcase) == true && user.id != user_id
                out << user
            end
        end
        return Sorter.search(out)
    end

    def self.find_friends(user, term)
        friendslist = user.friendslist
        out = []
        friendslist.each do |friend|
            if Search.partial_match(friend.username.downcase, term.downcase) == true
                out << friend
            end
        end
        return Sorter.search(out)
    end

end