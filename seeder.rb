require 'sqlite3'
require 'bcrypt'
Dir.glob('models/*.rb') { |model| require_relative model }

# Public: Resets the database and adds some data.
#
# db  - The database.
class Seeder

    # Public: Calls the different functions to reset the database.
    #
    # db  - The database.
    def self.seed!
        db = connect
        drop_tables(db)
        create_tables(db)
        populate_tables(db)
    end

    # Public: Connects to the database.
    # 
    # Returns the database.
    def self.connect
        SQLite3::Database.new "db/websnap.db"
    end

    # Public: Deletes the tables.
    #
    # db  - The database.
    def self.drop_tables(db)
        db.execute("DROP TABLE IF EXISTS users;")
        db.execute("DROP TABLE IF EXISTS messages;")
        db.execute("DROP TABLE IF EXISTS friends;")
        db.execute("DROP TABLE IF EXISTS groups")
        db.execute("DROP TABLE IF EXISTS groups_handler")
        db.execute("DROP TABLE IF EXISTS groups_messages")
        db.execute("DROP TABLE IF EXISTS reports")
    end

    # Public: Creates the tables.
    #
    # db  - The database.
    def self.create_tables(db)
        db.execute <<-SQL
            CREATE TABLE "users" (
                "id" INTEGER PRIMARY KEY AUTOINCREMENT,
                "username" TEXT NOT NULL UNIQUE,
                "password_hash" TEXT NOT NULL,
                "admin" INTEGER NOT NULL
            );
        SQL
        db.execute <<-SQL
            CREATE TABLE "messages" (
                "id" INTEGER PRIMARY KEY AUTOINCREMENT,
                "text" TEXT NOT NULL,
                "timestamp" TEXT NOT NULL,
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
                "last_interaction" TEXT NOT NULL
            );
        SQL
        db.execute <<-SQL
            CREATE TABLE "groups" (
                "id" INTEGER PRIMARY KEY AUTOINCREMENT,
                "name" TEXT NOT NULL,
                "last_interaction" TEXT NOT NULL
            );
        SQL
        db.execute <<-SQL
            CREATE TABLE "groups_handler" (
                "group_id" INTEGER NOT NULL,
                "user_id" INTEGER NOT NULL
            );
        SQL
        db.execute <<-SQL
            CREATE TABLE "groups_messages" (
                "id" INTEGER PRIMARY KEY AUTOINCREMENT,
                "text" TEXT,
                "timestamp" TEXT NOT NULL,
                "group_id" INTEGER NOT NULL,
                "sender_id" INTEGER NOT NULL
            );
        SQL
        db.execute <<-SQL
            CREATE TABLE "reports" (
                "id" INTEGER PRIMARY KEY AUTOINCREMENT,
                "accused" INTEGER NOT NULL,
                "accuser" INTEGER NOT NULL,
                "reason" TEXT NOT NULL
            );
        SQL
    end

    # Public: Adds data to some of the database tables
    #
    # db  - The database.
    def self.populate_tables(db)
        users = [
            {username: "Tester1", password_hash: BCrypt::Password.create("1"), admin: 1},
            {username: "Tester2", password_hash: BCrypt::Password.create("2"), admin: 0},
            {username: "Tester3", password_hash: BCrypt::Password.create("3"), admin: 0}
        ]

        users.each do |user|
            db.execute("INSERT INTO users (username, password_hash, admin) VALUES(?,?,?)", user[:username], user[:password_hash], user[:admin])
        end

        messages = [
            {text: "Message test 1", sender_id: 3, reciever_id: 1},
            {text: "Message test 2", sender_id: 2, reciever_id: 1},
            {text: "Message test 3", sender_id: 2, reciever_id: 1},
            {text: "Message test 4", sender_id: 2, reciever_id: 1}
        ]

        messages.each do |message|
            db.execute("INSERT INTO messages (text, timestamp, sender_id, reciever_id) VALUES(?,?,?,?)", message[:text], "#{Time.now}", message[:sender_id], message[:reciever_id])
        end

        friends = [
            {user_id: 1, user2_id: 2, status: 0, last_interaction: "#{Time.now}"},
            {user_id: 3, user2_id: 1, status: 0, last_interaction: "#{Time.now}"}
        ]

        friends.each do |friend|
            db.execute("INSERT INTO friends (user_id, user2_id, status, last_interaction) VALUES(?,?,?,?)", friend[:user_id], friend[:user2_id], friend[:status], friend[:last_interaction])
        end
    end

    Seeder.seed!
end