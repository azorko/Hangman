class Hangman
  
  attr_accessor :master, :guesser
  
  def initialize(master = ComputerPlayer.new, guesser = ComputerPlayer.new)
    @master = master
    @guesser = guesser
  end
  
  def play
    guesser.get_mystery(master.pick_secret_word)
    display
    10.times do
      master.handle_guess(guesser.guess)
      display
      if won? 
        puts "Congratulations!"
        return
      end
    end
    puts "Game Over..."
  end
  
  def won?
    !master.output.include?("_")
  end
  
  def display
    puts "Guessed letters: #{guesser.guesses}"
    puts "Mystery word: #{master.output.join}"
  end
end

# 


class ComputerPlayer
  
  attr_accessor :guesses, :secret, :output, :mystery, :words
  
  def initialize
    @guesses = []
    @secret = []
    @output = []
    @mystery = []
    @words = File.read('dictionary.txt').split
  end
  
  def get_mystery(mystery)
    self.mystery = mystery
  end
    
  def guess # done by guesser
   
    
    loop do
      filter_by_length
      filter_by_position
      guess = filter_by_frequency
      unless guesses.include?(guess)
        guesses << guess
        return guess
      end
    end
  end
  
  def handle_guess(guess) # Done by master
    
    self.secret.each_with_index do |ch, ind|
      self.output[ind] = guess if ch == guess
    end
  end
  
  def pick_secret_word
    self.secret = File.read('dictionary.txt').split.sample.split('')
    self.output = ('_' * secret.length).split('')
    
    output
  end
  
  def filter_by_length
    self.words = words.select { |word| word.length == mystery.length}
  end
  
  def filter_by_position
    regexp = []
    mystery.each do |ch|
      if ch == '_'
        regexp << '.'
      else
        regexp << ch
      end
    end
    regexp = Regexp.new(regexp.join)
    self.words = words.select { |word| regexp === word }
  end
  
  def filter_by_frequency
    guess_hash = Hash.new { |h, k| h[k] = 0 }
    words.join.each_char do |letter|
      guess_hash[letter] += 1
    end
    max = 0
    max_key = ""
    guess_hash.each do |key, val|
      if max < val && !guesses.include?(key)
        max_key = key
        max = val
      end
    end 
    max_key
  end
  
end

class HumanPlayer
  
  attr_accessor :output, :guesses
  
  def initialize
    @guesses = []
    @output = []
  end
  
  def check_guess?(guess) #call with comp_obj.letter
    answer = ""
    until answer == "y" || answer == "n"
      puts "Is #{guess} in your word? (y/n)"
      answer = gets.chomp
    end
    answer == 'y'
  end
  
  def get_mystery(mystery) # Dummy!
  end
  
  def guess
    loop do
      puts "Guess a letter"
      guess = gets.chomp.downcase
      if String(/[a-z]/.match(guess)) == guess
        guesses << guess
        return guess
      end
    end
  end

  def handle_guess(guess)
    if check_guess?(guess)
      loop do
        puts "Please submit your word with underscores for the unguessed
        letters (_a_ for 'cat' with 'a' guessed)"
      
        mystery_word = gets.chomp.split('')
        p mystery_word.count
        p output.count
        if output.count == mystery_word.count
          self.output = mystery_word
          return
        end
      end
    end
  end
  
  def pick_secret_word
    puts "What is the length of your secret word?"
    self.output = ('_' * Integer(gets.chomp)).split('')
    
    output
  end
end

Hangman.new.play
