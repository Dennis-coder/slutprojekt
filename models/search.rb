# The class that handles all search functions.
class Search

    # Checks if the term is a part of the username.
    # 
    # username - The username to be checked.
    # term - The search term.
    # matched - The amount of matching characters.
    # 
    # Returns true or false
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

    # Finds all users with a username that contains the serach term.
    # 
    # term - The search term.
    # user_id - Your own user id.
    # user_ids - All user ids.
    # 
    # Returns a list with all users with a username that contains the search term.
    def self.find_users(term, user_id)
        user_ids = User.all
        users = []
        user_ids.each do |id|
            users << User.get(id['id'])
        end
        out = []
        users.each do |user|
            if Search.partial_match(user.username.downcase, term.downcase) == true && user.id != user_id && user.username != 'Deleted user'
                out << user
            end
        end
        return out
    end

    # Finds all friends with a username that contains the serach term.
    # 
    # term - The search term.
    # user - Your own user.
    # friendslist - All friends id.
    # 
    # Returns a list with all friends with a username that contains the search term.
    def self.find_friends(user, term)
        friendslist = user.friendslist
        out = []
        friendslist.each do |friend|
            if Search.partial_match(friend.username.downcase, term.downcase) == true
                out << friend
            end
        end
        return out
    end

end