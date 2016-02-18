require 'pg'
require 'pry'



class Contact
attr_accessor :name, :email, :id
attr_reader :update
  def initialize(name, email, id = nil)
    @name = name
    @email = email
    @id = id
  end



  def persisted?
    !id.nil?
  end

  def save
    if persisted?
      self.class.login.exec_params("UPDATE contacts SET name=$1, email=$2 WHERE id=$3;", [@name, @email, @id])
    else
      result = self.class.login.exec_params("INSERT INTO contacts (name, email) VALUES ($1, $2) RETURNING id;", [name, email])
      @id = result[0]["id"]
    end
  end


  def update(id)
    individual_record = Contact.find(id)
    puts "Please enter your name "
    name = gets.chomp
    self.id = id
    self.name = name
    puts "Please enter your email "
    email = gets.chomp
    self.email = email
    self.save
  end
  
  def destroy
  end

  class << self


    def login
      PG.connect(host:'localhost', dbname: 'contactapp', user: 'development', password: 'development')
    end

    def all 
      results = login.exec_params("SELECT * FROM contacts;")
      process(results)
    end

    def create(name, email)
      result = login.exec_params("INSERT INTO contacts(name, email) VALUES ($1, $2) RETURNING id;"), [name, email]
      self.new(name, email, result[0]["id"].to_i)
    end

    def find(id)
      result = login.exec_params("SELECT * FROM contacts WHERE id=$1 LIMIT 1;",[id])
    end

    def search(key, value)
      results = login.exec_params("SELECT * FROM contacts WHERE #{key}=$1;",[value])
      process(results)
    end

    def process(results)
      array = Array.new

      results.each do |key|
        array << Contact.new(key["name"], key["email"], key["id"])
      end
      array
    end
  end
end

