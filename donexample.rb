donexample.rb

class Bicycle
  attr_accessor :name, :colour, :model
  attr_reader :id
  CONN = PG::Connection.new(host: 'localhost', port: 5432, dbname: 'ormdemo')

  def initialize(name, colour, model, id=nil)
    @name = name
    @colour = colour
    @model = model
    @id = id
  end

  def persisted?
    !id.nil?
  end

  def save
    if persisted?
      CONN.exec_params("UPDATE bicycles SET name=$1, colour=$2, model=$3 WHERE id=$4;", [@name, @colour, @model, @id])
    else
      result = CONN.exec_params("INSERT INTO bicycles (name, colour, model) VALUES ($1, $2, $3) RETURNING id;", [name, colour, model])
      @id = result[0]["id"]
    end
  end

  def destroy
    CONN.exec_params("DELETE FROM bicycles WHERE id=$1;", [@id])
    self.garbage_collect
  end

  def self.debug
    p CONN
  end

  def self.create(name, colour, model)
    result = CONN.exec_params("INSERT INTO bicycles (name, colour, model) VALUES ($1, $2, $3) RETURNING id;", [name, colour, model])
    self.new(name, colour, model, result[0]["id"].to_i)
  end

  def self.all
    results = CONN.exec_params("SELECT * FROM bicycles;")

    process_results(results)
  end

  def self.find(id)
    result = CONN.exec_params("SELECT * FROM bicycles WHERE id=$1 LIMIT 1;", [id])
    bike = result[0]

    Bicycle.new(bike["name"], bike["colour"], bike["model"], bike["id"])
  end

  def self.where(key, value)
    results = CONN.exec_params("SELECT * FROM bicycles WHERE #{key}=$1;", [value])

    process_results(results)
  end

  def self.process_results(results)
    bikes = []

    results.each do |bike|
      bikes << Bicycle.new(bike["name"], bike["colour"], bike["model"], bike["id"]) 
    end

    bikes 
  end
end
Raw  bicycles.sql
CREATE TABLE bicycles (
    id integer NOT NULL,
    name character varying(100),
    colour character varying(24),
    model character varying(48)
);

ALTER TABLE ONLY bicycles
    ADD CONSTRAINT bicycles_pkey PRIMARY KEY (id);
 @mafelix
           
Write Preview

Leave a comment
Attach files by dragging & dropping,  Choose Files selecting them, or pasting from the clipboard.
 Styling with Markdown is supported
Comment
Status API Training Shop Blog About Pricing
© 2016 GitHub, Inc. Terms Privacy Security Contact Help