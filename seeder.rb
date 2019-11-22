require 'sqlite3'
require 'bcrypt'
Dir.glob('models/*.rb') { |model| require_relative model }

class Seeder

    def self.seed!
        db = connect
        drop_tables(db)
        create_tables(db)
        populate_tables(db)
    end

    def self.connect
        SQLite3::Database.new "db/websnap.db"
    end

    def self.drop_tables(db)
        db.execute("DROP TABLE IF EXISTS users;")
        db.execute("DROP TABLE IF EXISTS messages;")
        db.execute("DROP TABLE IF EXISTS friends;")
    end

    def self.create_tables(db)
        db.execute <<-SQL
            CREATE TABLE "users" (
                "id" INTEGER PRIMARY KEY AUTOINCREMENT,
                "username" TEXT NOT NULL UNIQUE,
                "email" TEXT NOT NULL,
                "password_hash" TEXT NOT NULL,
                "sign_up_date" TEXT NOT NULL,
                "admin" INTEGER NOT NULL,
                "geotag" TEXT NOT NULL
            );
        SQL
        db.execute <<-SQL
            CREATE TABLE "messages" (
                "id" INTEGER PRIMARY KEY AUTOINCREMENT,
                "text" TEXT NOT NULL,
                "image" TEXT,
                "timestamp" TEXT NOT NULL,
                "geotag" TEXT NOT NULL,
                "status" INTEGER NOT NULL,
                "sender_id" INTEGER NOT NULL,
                "reciever_id" INTEGER NOT NULL
            );
        SQL
        db.execute <<-SQL
            CREATE TABLE "friends" (
                "user_id" INTEGER NOT NULL,
                "friends_id" INTEGER NOT NULL,
                "last_interaction" TEXT NOT NULL,
                "friends_since" TEXT NOT NULL
            );
        SQL
    end

    def self.populate_tables(db)
        users = [
            {username: "1", email: "1@gmail.com", password_hash: BCrypt::Password.create("1"), sign_up_date: "#{Time.now.utc}", admin: 1, geotag: "gothenburg"},
            {username: "2", email: "2@gmail.com", password_hash: BCrypt::Password.create("2"), sign_up_date: "#{Time.now.utc}", admin: 0, geotag: "gothenburg"},
            {username: "3", email: "3@gmail.com", password_hash: BCrypt::Password.create("3"), sign_up_date: "#{Time.now.utc}", admin: 0, geotag: "gothenburg"}
        ]

        users.each do |user|
            db.execute("INSERT INTO users (username, email, password_hash, sign_up_date, admin, geotag) VALUES(?,?,?,?,?,?)", user[:username], user[:email], user[:password_hash], user[:sign_up_date], user[:admin], user[:geotag])
        end

        messages = [
            {text: "Message test 1", image: "", geotag: "gothenburg", status: 1, sender_id: 3, reciever_id: 1},
            {text: "Message test 2", image: "", geotag: "gothenburg", status: 1, sender_id: 2, reciever_id: 1},
            {text: "Message test 3", image: "", geotag: "gothenburg", status: 1, sender_id: 2, reciever_id: 1},
            {text: "Message test 4", image: "", geotag: "gothenburg", status: 1, sender_id: 2, reciever_id: 1}
        ]

        messages.each do |message|
            Message.send(message[:text], message[:geotag], message[:sender_id], message[:reciever_id])
        end

        friends = [
            {user_id: 1, friends_id: 2, last_interaction: "#{Time.now.utc}", friends_since: "#{Time.now.utc}"},
            {user_id: 2, friends_id: 1, last_interaction: "#{Time.now.utc}", friends_since: "#{Time.now.utc}"},
            {user_id: 1, friends_id: 3, last_interaction: "#{Time.now.utc}", friends_since: "#{Time.now.utc}"},
            {user_id: 3, friends_id: 1, last_interaction: "#{Time.now.utc}", friends_since: "#{Time.now.utc}"}
        ]

        friends.each do |friend|
            db.execute("INSERT INTO friends (user_id, friends_id, last_interaction, friends_since) VALUES(?,?,?,?)", friend[:user_id], friend[:friends_id], friend[:last_interaction], friend[:friends_since])
        end
    end

end

Seeder.seed!