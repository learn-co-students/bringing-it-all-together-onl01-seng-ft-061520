

class Dog
    attr_accessor :name, :breed
    attr_reader :id

    def initialize(id: nil, name:, breed:)
        @id = id
        @name = name
        @breed = breed

    end

    def self.create_table
        sql = <<-SQL
            CREATE TABLE IF NOT EXISTS dogs (
                id INTEGER PRIMARY KEY,
                name TEXT,
                breed TEXT
            );
        SQL

        DB[:conn].execute(sql)
    end

    def self.drop_table
        DB[:conn].execute("DROP TABLE dogs;")
    end

    def save
        
            sql = <<-SQL
                INSERT INTO dogs (name, breed)
                VALUES (?, ?);
            SQL

            DB[:conn].execute(sql, self.name, self.breed)
            @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        
        Dog.find_by_id(self.id)
    end

    def self.find_by_id(id)
        sql = "SELECT * FROM dogs WHERE id = ?"
        dog_row = DB[:conn].execute(sql, id)[0]

        Dog.new(id: dog_row[0], name: dog_row[1], breed: dog_row[2])
    end

    def self.create(dog_attributes_hash)
        # dog_attributes_hash =>    {:name=>"Ralph", :breed=>"lab"}

        dog = Dog.new(name: dog_attributes_hash[:name], breed: dog_attributes_hash[:breed])
        dog.save
    end

    def self.new_from_db(dog_attributes_row)
        # dog_attributes_row =>     [1, "Pat", "poodle"]

        Dog.new(id: dog_attributes_row[0], name: dog_attributes_row[1], breed: dog_attributes_row[2])
    end

    # creates an instance of a dog if it does not already exist 
    def self.find_or_create_by(name:, breed:)

        sql = <<-SQL
        SELECT * FROM dogs WHERE name = ? AND breed = ?;
        SQL

       answer = DB[:conn].execute(sql, name, breed)

       if !answer.empty?
            answer = self.new_from_db(answer[0])
       else
            answer = self.create(name: name, breed: breed)
       end

       answer
    end

    # returns an instance of dog that matches the name from the DB 
    def self.find_by_name(name)
        sql = <<-SQL
            SELECT * FROM dogs WHERE dogs.name = ?;
        SQL

        dog_row = DB[:conn].execute(sql, name).flatten
        self.new_from_db(dog_row)
    end

    # updates the record associated with a given instance
    def update

        sql = <<-SQL
            UPDATE dogs SET id = ?, name = ?, breed = ?;
        SQL

        DB[:conn].execute(sql, self.id, self.name, self.breed)
    end








end
