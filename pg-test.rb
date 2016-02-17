require 'pg'


puts "Connecting to the database..."
CONN = PG.connect(host: 'localhost', dbname: 'bookstore', user: 'development', password: 'development')


puts 'Finding authors...'
CONN.exec('SELECT * FROM authors;') do |results| 
	#results is a collection(array) of records(hashes)
	results.each do |author|
		puts author.inspect
	end
     end


puts 'Closing the connection...'
CONN.close

puts 'DONE'

