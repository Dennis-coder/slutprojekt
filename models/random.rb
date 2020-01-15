class Randoms

    def self.match?(term, user)
        length = term.length
        matched = 0
        user.each_char do |char|
            if char = term[i]
                i += 1
            else
                i = 0
            end
            if i = length - 1
                return true
            end
        end
        return false
    end

    def self.everybody(term)
        users = User.all_users()
        out = []
        users.each do |user|
            if randoms.match?(term, user) == true
                out << user
            end
        end
    end

    def self.by_last_interaction(id)
        friends_id = Friend.friendslist(id)
        friends = []
        unless friends_id.empty?
            friends_id.each do |friend_id|
                friend = {}
                friend['username'] = User.username(friend_id)
                friend['last_interaction'] = Friend.last_interaction(id, friend_id)
                friends << friend
            end
            friends.first
        end
        return friends
    end

    def self.friends(id, term)
        temp = Friend.friendslist(id)
        friends = []
        out = []
        temp.each do |friend_id|
            friends << User.username(friend_id)
        end
        friends.each do |friend|
            if randoms.match?(term, friend) == true
                out << fiend
            end
        end
    end

end