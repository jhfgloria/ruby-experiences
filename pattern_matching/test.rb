# frozen_string_literal: true

def parse_expression(expression)
  case expression
  in error:
    puts "this is an error: #{error}"
  in data:
    puts "this is the data: #{data}"
  else
    puts 'unknown payload'
  end
end

parse_expression({ error: 'Something went wrong' }) # match
parse_expression({ data: { a: 1, b: 2 } })          # match
parse_expression({ config: { name: 'FooBar' } })    # no match

# pattern matching can bind to variables
{ config: { user: 'Foo' } } => { config: { user: } }
puts "This is the user name: #{user}"
## or
{ config: { user: 'Bar' } } in { config: { user: } }
puts "This is the user name: #{user}"

users = [{ name: 'Foo', age: 29 }, { name: 'Bar', age: 24 }]
older_than_twenty_five = users.filter { |user| user in { age: 25.. } }
puts older_than_twenty_five

# pattern matching in Ruby can have join types using the | operator
# this allows having a match between multiple patterns
def integer_or_string_pattern(expression)
  case expression
  in String | Integer
    puts 'integer or string'
  else
    puts 'something else'
  end
end

integer_or_string_pattern(1)                        # match - integer or string
integer_or_string_pattern('hello world')            # match - integer or string
integer_or_string_pattern({ name: 'Foo', age: 12 }) # no match - something else

# pattern matching for arrays needs to mactch the whole array
def array_with_size_three(array)
  case array
  in [Integer, Integer, Integer]
    puts 'matched the array size'
  else
    puts 'did not match'
  end
end

array_with_size_three([1, 2, 3])    # match
array_with_size_three([1, 2, 3, 4]) # no match

# hashes only need to match partially, except the empty hash
# which only matches the empty hash itself
def hash_with_string_name(hash)
  case hash
  in {}
    puts 'empty hash'
  in name: String
    puts 'hash has name'
  else
    puts 'did not match'
  end
end

hash_with_string_name({ name: 'Joao' }) # match
hash_with_string_name({ name: 44 })     # no match
hash_with_string_name({ age: 20 })      # no match

# hashes can be specify which keys should contain with the
# pattern using the **nil pattern
def hash_with_token_only(hash)
  case hash
  # variable binging is made through the => operator
  in token: String => token
    puts "token is here: #{token}"
  else
    puts 'unknown format'
  end
end

hash_with_token_only({ token: 'xyz' })                       # match
hash_with_token_only({ token: 'zyx', refresh_token: 'foo' }) # no match

# head, tail, and rest can be achieved using * (array) and ** (hash).
# apparently hashes do not support **rest in the beginning of the
# pattern, only in the end.
def head_and_tail(expression)
  case expression
  in [*head, Integer => middle, *tail]
    puts "head is: #{head}, middle is: #{middle} and tail is: #{tail}"
  in name: String => head, **tail
    puts "head is: #{head}, and tail is: #{tail}"
  else
    puts 'no match'
  end
end

head_and_tail(['a', 2, 3, 4, 5, 6, 7])           # match - head is: ["a"], middle is: 2 and tail is: [3, 4, 5, 6, 7]
head_and_tail({ name: 'Foo', a: 1, b: 2, c: 3 }) # match - head is: Foo, and tail is: {:a=>1, :b=>2, :c=>3}

def bind_nested_values(expression)
  case expression
  in data: { members: [first_member, *] }
    puts "first member is #{first_member}"
  else
    puts 'no match'
  end
end

bind_nested_values({ data: { members: [{ name: 'Foo' }, { name: 'Bar' }] } }) # match - first member is {:name=>"Foo"}
bind_nested_values({ data: { pets: [{ name: 'Foo' }, { name: 'Bar' }] } })    # no match

# value binding replaces the original value if the pattern is built from actual values
# instead of just an expression
expectation = 18
[1, 2] => [expectation, 2]
puts "expectaction was: #{expectation}" # expectaction was: 1 - the value 18 is lost in the binding

# to avoid overriding values with pattern matching there's the pinning operator (^)
def pattern_match_with_pinning(expectation)
  expression = [1, 2]

  case expression
  in [^expectation, 2]
    puts "expectation was: #{expectation}"
  else
    puts 'did not match'
  end
end

pattern_match_with_pinning(1)  # match - expectation was: 1
pattern_match_with_pinning(18) # did not match

# pinning is also valuable if we want to bind a value in the pattern and use it in the same
# pattern to match a different part of it
def last_name_in_list(expression)
  case expression
  in name:, list: [*, { name: ^name }]
    puts "#{name} is last in list"
  else
    puts 'did not match'
  end
end

last_name_in_list({ name: 'Bar', list: [{ name: 'Foo' }, { name: 'Bar' }] })
last_name_in_list({ name: 'FooBar', list: [{ name: 'Foo' }, { name: 'Bar' }] })

# non-primitive objects can also be pattern-matched as long as they implement one (or both)
# of the two methods: deconstruct or deconstruct_keys, internally used for array and hash
# patterns respectivelly
class RockPaperScissorMatch
  def initialize(player1, player2)
    @p1 = player1
    @p2 = player2
  end

  def deconstruct
    [@p1, @p2]
  end

  def deconstruct_keys(_keys)
    { p1: @p1, p2: @p2 }
  end
end

case RockPaperScissorMatch.new('paper', 'rock')
in 'rock', 'paper'
  puts 'You win'
in 'paper', 'rock'
  puts 'You lose'
else
  puts 'DRAW!'
end

RockPaperScissorMatch.new('paper', 'rock') => { p1:, p2: }
puts "Player 1 played #{p1} and Player 2 played #{p2}"

# using classes to pattern match is also possible and Ruby
# will use === to compare which will enforce class comparison
# Testing against super classes or sub classes won't work
case RockPaperScissorMatch.new('paper', 'rock')
in RockPaperScissorMatch['rock', 'paper']
  puts 'You win'
in RockPaperScissorMatch['paper', 'rock']
  puts 'You lose'
else
  puts 'DRAW!'
end

[0] => [*, 0, *]

# it is also possible to match values based on a guard criteria
expression = [2, 4]
case expression
in 2 => a, b if b >= a * 2
  puts 'match'
else
  puts 'did not match'
end
