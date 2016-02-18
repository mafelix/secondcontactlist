require 'pg'
require 'pry'

class Contact
  attr_accessor :name, :email
  attr_reader :id

  def initialize(id = nil, name = nil, email = nil)
    @id = id
    @name = name
    @email = email
  end



  def data
    !id.nil?
  end

  def save
    if self.class.find(id)
      self.class.connection.exec_params("UPDATE contacts SET name=$1, email=$2 WHERE id=$3;", [@name, @email, @id])
    else
      result = self.class.connection.exec_params("INSERT INTO contacts (name, email, id) VALUES ($1, $2, $3) RETURNING id;", [name, email, id])
      @id = result[0]["id"]
    end
  end

  def destroy(id)
    if self.class.find(id)
      self.class.connection.exec_params("DELETE FROM contacts WHERE id=$3;",[id])
    else
      puts "Id isn't there to destroy"
    end
    binding.pry
  end


  def self.connection
    PG.connect(host:'localhost', dbname: 'contactapp', user: 'development', password: 'development')
  end


  def self.all
    results = connection.exec("SELECT * FROM contacts;")
    process(results)
  end



  def self.create(name, email)
    results = connection.exec_params("INSERT INTO contacts (name, email) VALUES ($1, $2) RETURNING id;", [name, email])
    self.new(name, email)
  end


  def self.find(id)
    result = connection.exec_params("SELECT * FROM contacts WHERE id=$1 LIMIT 1;", [id]) 
    if result.num_tuples != 0
      person = result[0]

      return Contact.new(person["id"], person["name"], person["email"])
    end
    false
  end
  

  def self.update(id)
    contact = Contact.find(id) || Contact.new(id)
    
    puts "Enter a new name "
    new_name = gets.chomp
    contact.name = new_name
    # connection.exec_params("UPDATE contacts SET name=$1", [new_name])
    puts "Enter a new email "
    new_email = gets.chomp 
    contact.email = new_email
    # connection.exec_params("UPDATE contacts SET email=$2", [new_email])
    contact.save   
  end

  def self.search(key, value)
    results = connection.exec_params("SELECT * FROM contacts WHERE #{key}=$1;", [value])
    process(results)
  end  

  def self.process(results) 
    array = Array.new

    results.each do |contact|
      array << Contact.new(contact["name"], contact["email"], contact["id"])
    end
    array

  end 
end
# p Contact.search("Hahaha","RubyProblems")
p Contact.destroy(3)
