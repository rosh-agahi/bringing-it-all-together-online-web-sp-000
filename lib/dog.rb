class Dog

  attr_accessor :id, :name, :breed

  def initialize(attributes)
    attributes.each do |key, value| self.send(("#{key}="), value)
    end
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
      )
      SQL
      
    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute('DROP TABLE dogs;')
  end
    
  def save
    if !self.id 
      insert = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?,?)
      SQL
      DB[:conn].execute(insert, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    else
      self.update
    end
    self 
  end

  def self.create(attributes_hash)
    new_dog = Dog.new(attributes_hash)
    new_dog.save
    new_dog
  end

  def self.new_from_db(row)
    id = row[0]
    name = row[1]
    breed = row[2]
    self.new(id: id, name: name, breed: breed)
  end

  def self.find_by_id(id)
    id_query = <<-SQL 
    SELECT * FROM dogs 
    WHERE id = ?
    SQL
    DB[:conn].execute(id_query,id).map do |row|
      self.new_from_db(row)
    end.first
  end

  def self.find_or_create_by(name:, breed:)
   sql = <<-SQL
         SELECT * FROM dogs
         WHERE name = ? AND breed = ?
         LIMIT 1
       SQL

   dog = DB[:conn].execute(sql,name,breed)

   if !dog.empty?
     dog_data = dog[0]
     dog = Dog.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
   else
     dog = Dog.create(name: name, breed: breed)
   end
   dog
 end

  def update
    update <<-SQL
    UPDATE dogs 
    SET name = ?, breed = ?
    WHERE id = ?
    SQL
    
    DB[:conn].execute(update, self.name, self.breed, self.id)
    
  end
  
  def insert 
    insert <<-SQL 
    INSERT INTO dogs (name, breed) 
    VALUES (?, ?)
    SQL
    
    DB[:conn].execute(insert, self.name, self.breed)
    self.id = DB[:conn].execute("SELECT last_insert_rowid();").flatten.first 
  end
  
    
end