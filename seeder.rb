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
                "password_hash" TEXT NOT NULL,
                "sign_up_date" TEXT NOT NULL,
                "admin" INTEGER NOT NULL
            );
        SQL
        db.execute <<-SQL
            CREATE TABLE "messages" (
                "id" INTEGER PRIMARY KEY AUTOINCREMENT,
                "text" TEXT NOT NULL,
                "image" TEXT,
                "timestamp" TEXT NOT NULL,
                "status" INTEGER NOT NULL,
                "sender_id" INTEGER NOT NULL,
                "reciever_id" INTEGER NOT NULL
            );
        SQL
        db.execute <<-SQL
            CREATE TABLE "friends" (
                "id" INTEGER PRIMARY KEY AUTOINCREMENT,
                "user_id" INTEGER NOT NULL,
                "user2_id" INTEGER NOT NULL,
                "status" INTEGER NOT NULL,
                "last_interaction" TEXT NOT NULL,
                "friends_since" TEXT NOT NULL
            );
        SQL
    end

    def self.populate_tables(db)
        users = [
            {username: "1", password_hash: BCrypt::Password.create("1"), sign_up_date: "#{Time.now.utc}", admin: 1},
            {username: "2", password_hash: BCrypt::Password.create("2"), sign_up_date: "#{Time.now.utc}", admin: 0},
            {username: "3", password_hash: BCrypt::Password.create("3"), sign_up_date: "#{Time.now.utc}", admin: 0}
        ]

        users.each do |user|
            db.execute("INSERT INTO users (username, password_hash, sign_up_date, admin) VALUES(?,?,?,?)", user[:username], user[:password_hash], user[:sign_up_date], user[:admin])
        end

        messages = [
            {text: "Message test 1", image: "", status: 1, sender_id: 3, reciever_id: 1},
            {text: "Message test 2", image: "", status: 1, sender_id: 2, reciever_id: 1},
            {text: "Message test 3", image: "", status: 1, sender_id: 2, reciever_id: 1},
            {text: "Message test 4", image: "", status: 1, sender_id: 2, reciever_id: 1}
        ]

        messages.each do |message|
            db.execute("INSERT INTO messages (text, image, timestamp, status, sender_id, reciever_id) VALUES(?,?,?,?,?,?)", message[:text], "", "#{Time.now.utc}", 1, message[:sender_id], message[:reciever_id])
        end

        friends = [
            {user_id: 1, user2_id: 2, status: 0, last_interaction: "#{Time.now.utc}", friends_since: "#{Time.now.utc}"},
            {user_id: 3, user2_id: 1, status: 1, last_interaction: "#{Time.now.utc}", friends_since: "#{Time.now.utc}"}
        ]

        friends.each do |friend|
            db.execute("INSERT INTO friends (user_id, user2_id, status, last_interaction, friends_since) VALUES(?,?,?,?,?)", friend[:user_id], friend[:user2_id], friend[:status], friend[:last_interaction], friend[:friends_since])
        end
    end

end

Seeder.seed!