#!/usr/bin/ruby

=begin
------------------------------------------------------------------------
 	File          : hello_world.rb
	Date          : 09-14-2016
	Program name  : Hello World in Ruby
	Version       : 0.0
	Author        : ----
	Enviroment    : CLI
	Description   : Just a simple ruby program to test basic functions on
					ruby

	Notes

------------------------------------------------------------------------
=end

# Starter functions
BEGIN {
	puts "Initializing Ruby Program"
	print "Line is ", __LINE__, "\n";
	print "File is ", __FILE__, "\n";
	time1 = Time.new
	puts "Current Time : " + time1.inspect
}

END {
	puts "Terminating Ruby Program"
}

class HelloWorld
	def initialize(name)
		@name = name.capitalize
	end
	def sayHi
		puts "Hello #{@name}!"
	end
end

class Sample1
	def hello
		puts "Hello Ruby!"
	end
end


class Customer
	def initialize(id, name, addr)
		@cust_id=id
		@cust_name=name
		@cust_addr=addr
	end
	def display_details()
		puts "Customer id #@cust_id"
		puts "Customer name #@cust_name"
		puts "Customer address #@cust_addr"
	end
end

# Method and functions area
def test(a1="Ruby", a2="Perl")
   puts "The programming language is #{a1}"
   puts "The programming language is #{a2}"
end

def test1
   i = 100
   j = 200
   k = 300
   return i, j, k
end


def sample (*test)
   puts "The number of parameters is #{test.length}"
   for i in 0...test.length
      puts "The parameters are #{test[i]}"
   end
end

def prime(n)
  puts "That's not an integer." unless n.is_a? Integer
  is_prime = true
  for i in 2..n-1
    if n % i == 0
      is_prime = false
    end
  end
  if is_prime
    puts "#{n} is prime!"
  else
    puts "#{n} is not prime."
  end
end



# Main Ruby program from this point on
puts "Main ruby program begins now."
puts "-----------------------------------"
print "Line is ", __LINE__, "\n";

puts "Run the Hello World class"
hello = HelloWorld.new("World")
hello.sayHi

# Now using above class to create objects
puts "-----------------------------------"
puts "Run the Sample1 class"
print "Line is ", __LINE__, "\n";
object = Sample1. new
object.hello


# Now using above class to create objects
puts "-----------------------------------"
puts "Run the Customer class..-"
print "Line is ", __LINE__, "\n";
# Create Objects
cust1=Customer.new("1", "John", "Wisdom Apartments, Ludhiya")
cust2=Customer.new("2", "Poul", "New Empire road, Khandala")

# Call Methods
cust1.display_details()
cust2.display_details()



puts "-----------------------------------"
puts "Simple arithmethic operations"
print "Line is ", __LINE__, "\n";
x = 10;
y = 25;
print "\n x = ", x;
print "\n y = ", y;
print "\n x + y = ", x + y;
print "\n x - y = ", x - y;
print "\n x * y = ", x * y;
print "\n x / y = ", x / y;
print "\n x % y = ", x % y;
print "\n x ** y = ", x**y;



# Testing simple functions
puts "\n-----------------------------------"
puts " Calling prime number function with these arguments"
puts " 2 , 9 , 11 , 51 , 97 "
print "Line is ", __LINE__, "\n";
prime(2)
prime(9)
prime(11)
prime(51)
prime(97)



# Testing input methods
puts "-----------------------------------"
puts " Testing input and hash methods "
print "Line is ", __LINE__, "\n";

puts "Text please: "
text = gets.chomp
words = text.split(" ")
frequencies = Hash.new(0)
words.each { |word| frequencies[word] += 1 }
frequencies = frequencies.sort_by {|a, b| b }
frequencies.reverse!
frequencies.each { |word, frequency| puts word + " " + frequency.to_s }


puts "\nChecking  a small loop (while)"
puts "-----------------------------------"
print "Line is ", __LINE__, "\n";
$i = 0
$num = 5

while $i < $num  do
   puts("Inside the loop i = #$i" )
   $i +=1
end

puts "Testing methods"
puts "-----------------------------------"
print "Line is ", __LINE__, "\n";
test "C", "C++"
test

puts "\nTesting value return"
puts "-----------------------------------"
print "Line is ", __LINE__, "\n";
var = test1
puts var

puts "\nTesting variable argument return and check"
puts "-----------------------------------"
print "Line is ", __LINE__, "\n";
sample "Zara", "6", "F"
sample "Mac", "36", "M", "MCA"


puts "\nTesting string unpack operations"
puts "-----------------------------------"
print "Line is ", __LINE__ , "\n";
print " abc \0\0abc \0\0".unpack('A6Z6') ,"\n";   #=> ["abc", "abc "]
print " abc \0\0".unpack('a3a3') ,"\n";           #=> ["abc", " \000\000"]
print " abc \0abc \0".unpack('Z*Z*') ,"\n";       #=> ["abc ", "abc "]
print " aa".unpack('b8B8') ,"\n";                 #=> ["10000110", "01100001"]
print " aaa".unpack('h2H2c') ,"\n";               #=> ["16", "61", 97]
print " \xfe\xff\xfe\xff".unpack('sS') ,"\n";     #=> [-2, 65534]
print " now=20is".unpack('M*') ,"\n";             #=> ["now is"]
print " whole".unpack('xax2aX2aX1aX2a') ,"\n";    #=> ["h", "e", "l", "l", "o"]

puts "\nTesting date, time , etc"
puts "-----------------------------------"
print "Line is ", __LINE__, "\n";
time = Time.new
# Components of a Time
puts "Current Time : " + time.inspect
puts time.year    # => Year of the date
puts time.month   # => Month of the date (1 to 12)
puts time.day     # => Day of the date (1 to 31 )
puts time.wday    # => 0: Day of week: 0 is Sunday
puts time.yday    # => 365: Day of year
puts time.hour    # => 23: 24-hour clock
puts time.min     # => 59
puts time.sec     # => 59
puts time.usec    # => 999999: microseconds
puts time.zone    # => "UTC": timezone name


=begin
Output MUSY be this :
Initializing Ruby Program
Current Time : 2016-09-16 00:17:29 +0000
Main ruby program begins now.
-----------------------------------
Check the Hello World class
Hello World!
-----------------------------------
Simple arithmethic operations
 x = 10
 y = 25
 x + y = 35
 x - y = -15
 x * y = 250
 x / y = 0
 x % y = 10
 x ** y = 10000000000000000000000000
Checking  a small loop (while)
-----------------------------------
Inside the loop i = 0
Inside the loop i = 1
Inside the loop i = 2
Inside the loop i = 3
Inside the loop i = 4
Testing methods
-----------------------------------
The programming language is C
The programming language is C++
The programming language is Ruby
The programming language is Perl
Testing value return
-----------------------------------
100
200
300
Testing variable argument return and check
-----------------------------------
The number of parameters is 3
The parameters are Zara
The parameters are 6
The parameters are F
The number of parameters is 4
The parameters are Mac
The parameters are 36
The parameters are M
The parameters are MCA
Testing string unpack operations
-----------------------------------
[" abc", ""]
[" ab", "c \x00"]
[" abc ", "abc "]
["00000100", "01100001"]
["02", "61", 97]
[-480, 65279]
[" now is"]
["w", "l", "o", "o", "h"]
Testing time
-----------------------------------
Current Time : 2016-09-16 00:17:29 +0000
2016
9
16
5
260
0
17
29
974223
UTC
Terminating Ruby Program
=end
