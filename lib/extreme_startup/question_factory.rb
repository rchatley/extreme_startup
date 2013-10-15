require 'set'
require 'prime'

module ExtremeStartup
  
  class Question
    attr_reader :duration
    
    class << self
      def generate_uuid
        @uuid_generator ||= UUID.new
        @uuid_generator.generate.to_s[0..7]
      end
    end

    def ask(player, timeout = 10)
      url = player.url + '?q=' + URI.escape(self.to_s)
      start = Time.now
      begin
        response = get(url, timeout)
        if response.success? then
          self.answer = response.to_s
        else
          @problem = "error_response"
        end
      rescue => exception
        puts exception
        @problem = "no_server_response"
      ensure
        @duration = Time.now - start
      end
    end

    def get(url, timeout = 10)
      HTTParty.get(url, :timeout => timeout)
    end

    def result
      if @answer && self.answered_correctly?(answer)
        "correct"
      elsif @answer
        "wrong"
      else
        @problem
      end
    end

    def delay_before_next
      case result
        when "correct"        then 5
        when "wrong"          then 10
        else 20
      end
    end
    
    def was_answered_correctly
      result == "correct"
    end
    
    def was_answered_wrongly
      result == "wrong"
    end

    def display_result
      "\tquestion: #{self.to_s}\n\tanswer: #{answer}\n\tresult: #{result}"
    end

    def id
      @id ||= Question.generate_uuid
    end

    def to_s
      "#{id}: #{as_text}"
    end

    def answer=(answer)
      @answer = answer.force_encoding("UTF-8")
    end

    def answer
      @answer && @answer.downcase.strip
    end

    def answered_correctly?(answer)
      correct_answer.to_s.downcase.strip == answer
    end

    def points
      10
    end
    
    # Provides base value of this question disregarding actual answer if defined
    # This method defaults to +points+ 
    def base_points
      points
    end
  end

  class BinaryMathsQuestion < Question
    def initialize(player, *numbers)
      if numbers.any?
        @n1, @n2 = *numbers
      else
        @n1, @n2 = rand(20), rand(20)
      end
    end
  end

  class TernaryMathsQuestion < Question
    def initialize(player, *numbers)
      if numbers.any?
        @n1, @n2, @n3 = *numbers
      else
        @n1, @n2, @n3 = rand(20), rand(20), rand(20)
      end
    end
  end

  class SelectFromListOfNumbersQuestion < Question
    def initialize(player, *numbers)
      if numbers.any?
        @numbers = *numbers
      else
        size = rand(2)
        @numbers = random_numbers[0..size].concat(candidate_numbers.shuffle[0..size]).shuffle
      end
    end

    def random_numbers
      randoms = Set.new
      loop do
        randoms << rand(1000)
        return randoms.to_a if randoms.size >= 5
      end
    end

    def correct_answer
       @numbers.select do |x|
         should_be_selected(x)
       end.join(', ')
     end
  end

  class MaximumQuestion < SelectFromListOfNumbersQuestion
    def as_text
      "which of the following numbers is the largest: " + @numbers.join(', ')
    end
    def points
      40
    end
    private
      def should_be_selected(x)
        x == @numbers.max
      end

      def candidate_numbers
          (1..100).to_a
      end
    end

  class AdditionQuestion < BinaryMathsQuestion
    def as_text
      "what is #{@n1} plus #{@n2}"
    end
  private
    def correct_answer
      @n1 + @n2
    end
  end

  class PlusQuestion < BinaryMathsQuestion
    def as_text
      "what is #{@n1} + #{@n2}"
    end
  private
    def correct_answer
      @n1 + @n2
    end
  end

  class SubtractionQuestion < BinaryMathsQuestion
    def as_text
      "what is #{@n1} minus #{@n2}"
    end
  private
    def correct_answer
      @n1 - @n2
    end
  end

  class MinusQuestion < BinaryMathsQuestion
    def as_text
      "what is #{@n1} - #{@n2}"
    end
  private
    def correct_answer
      @n1 - @n2
    end
  end

  class MultiplicationQuestion < BinaryMathsQuestion
    def as_text
      "what is #{@n1} multiplied by #{@n2}"
    end
  private
    def correct_answer
      @n1 * @n2
    end
  end

  class MultQuestion < BinaryMathsQuestion
    def as_text
      "what is #{@n1} * #{@n2}"
    end
  private
    def correct_answer
      @n1 * @n2
    end
  end

  # Generates arbitrary arithmetic questions with 'plus', 'times' and 'minus' operators.
  # 
  # Generated expression should be evaluated from left to right respecting usual precedence of 
  # operators: * binds tighter than +. This means the expression 
  #   12 + 3 * 4 + 5
  #  
  # evaluates to 29 and not 65.  
  # 
  class GeneralArithmeticQuestion < Question

    @@operators = ['plus', 'minus', 'times']

    def initialize(player, *tokens)
      if tokens.any?
        @tokens = tokens
      else
        @tokens = generate_expression()
      end
    end

    def points
      60
    end

    def as_text
      "what is " + expression
    end

    private

    def generate_expression
      exp = []
      (rand(8) + 1).times { exp += [ rand(100), @@operators.sample ] } 
      exp + [ rand(100) ]
    end

    def expression
      @tokens.inject('') do |txt, tok|
        txt + ("%s " % tok)
      end
    end

    def evaluable_expression
      @tokens.map do |tok|
        if tok == "plus" then
          "+"
        elsif tok == "times"  then
          "*"
        elsif tok == "minus"  then
          "-"
        else 
          tok
        end 
      end.inject('') do |txt, tok|
        txt + ("%s " % tok)
      end
    end

    def correct_answer
      eval(evaluable_expression)
    end
  end

  class AdditionAdditionQuestion < TernaryMathsQuestion
    def as_text
      "what is #{@n1} plus #{@n2} plus #{@n3}"
    end
    def points
      30
    end
  private
    def correct_answer
      @n1 + @n2 + @n3
    end
  end

  class AdditionMultiplicationQuestion < TernaryMathsQuestion
    def as_text
      "what is #{@n1} plus #{@n2} multiplied by #{@n3}"
    end
    def points
      60
    end
  private
    def correct_answer
      @n1 + @n2 * @n3
    end
  end

  class MultiplicationAdditionQuestion < TernaryMathsQuestion
    def as_text
      "what is #{@n1} multiplied by #{@n2} plus #{@n3}"
    end
    def points
      50
    end
  private
    def correct_answer
      @n1 * @n2 + @n3
    end
  end

  class PowerQuestion < BinaryMathsQuestion
    def as_text
      "what is #{@n1} to the power of #{@n2}"
    end
    def points
      20
    end
  private
    def correct_answer
      @n1 ** @n2
    end
  end

  class SquareCubeQuestion < SelectFromListOfNumbersQuestion
    def as_text
      "which of the following numbers is both a square and a cube: " + @numbers.join(', ')
    end
    def points
      60
    end
  private
    def should_be_selected(x)
      is_square(x) and is_cube(x)
    end

    def candidate_numbers
        square_cubes = (1..100).map { |x| x ** 3 }.select{ |x| is_square(x) }
        squares = (1..50).map { |x| x ** 2 }
        square_cubes.concat(squares)
    end

    def is_square(x)
      if (x ==0)
        return true
      end
      (x % (Math.sqrt(x).round(4))) == 0
    end

    def is_cube(x)
      if x ==0
        return true
      end
      (x % (Math.cbrt(x).round(4))) == 0
    end
  end

  class PrimesQuestion < SelectFromListOfNumbersQuestion
     def as_text
       "which of the following numbers are primes: " + @numbers.join(', ')
     end
     def points
       60
     end
   private
     def should_be_selected(x)
       Prime.prime? x
     end

     def candidate_numbers
       Prime.take(100)
     end
   end

  class FibonacciQuestion < BinaryMathsQuestion
    def as_text
      n = @n1 + 4
      if n > 20 && n % 10 == 1
        return "what is the #{n}st number in the Fibonacci sequence"
      end
      if n > 20 && n % 10 == 2
        return "what is the #{n}nd number in the Fibonacci sequence"
      end
      "what is the #{n}th number in the Fibonacci sequence"
    end
    def points
      50
    end
  private
    def correct_answer
      n = @n1 + 4
      a, b = 0, 1
      n.times { a, b = b, a + b }
      a
    end
  end

  class GeneralKnowledgeQuestion < Question
    class << self
      def question_bank
        [
          ["who is the Prime Minister of Great Britain", "David Cameron"],
          ["which city is the Eiffel tower in", "Paris"],
          ["what currency did Spain use before the Euro", "peseta"],
          ["what colour is a banana", "yellow"],
          ["who played James Bond in the film Dr No", "Sean Connery"],
          ["what is the name of the narrator in Proust's 'La recherche du temps perdu'", ""],
          ["what is the capital city of Botswana", "Gaborone"],
          ["what is the date of BloomsDay", "16 June"]
        ]
      end
    end

    def initialize(player)
      question = GeneralKnowledgeQuestion.question_bank.sample
      @question = question[0]
      @correct_answer = question[1]
    end

    def as_text
      @question
    end

    def correct_answer
      @correct_answer
    end
  end

  require 'yaml'
  class AnagramQuestion < Question
    def as_text
      possible_words = [@anagram["correct"]] + @anagram["incorrect"]
      %Q{which of the following is an anagram of "#{@anagram["anagram"]}": #{possible_words.shuffle.join(", ")}}
    end

    def initialize(player, *words)
      if words.any?
        @anagram = {}
        @anagram["anagram"], @anagram["correct"], *@anagram["incorrect"] = words
      else
        anagrams = YAML.load_file(File.join(File.dirname(__FILE__), "anagrams.yaml"))
        @anagram = anagrams.sample
      end
    end

    def correct_answer
      @anagram["correct"]
    end
  end

  class ScrabbleQuestion < Question
    def as_text
      "what is the english scrabble score of #{@word}"
    end

    def initialize(player, word=nil)
      if word
        @word = word
      else
        @word = ["banana", "september", "cloud", "zoo", "ruby", "buzzword"].sample
      end
    end

    def correct_answer
      @word.chars.inject(0) do |score, letter|
        score += scrabble_scores[letter.downcase]
      end
    end

    private

    def scrabble_scores
      scores = {}
      %w{e a i o n r t l s u}.each  {|l| scores[l] = 1 }
      %w{d g}.each                  {|l| scores[l] = 2 }
      %w{b c m p}.each              {|l| scores[l] = 3 }
      %w{f h v w y}.each            {|l| scores[l] = 4 }
      %w{k}.each                    {|l| scores[l] = 5 }
      %w{j x}.each                  {|l| scores[l] = 8 }
      %w{q z}.each                  {|l| scores[l] = 10 }
      scores
    end
  end

  class Location
    def initialize(name, weather)
      @name = name
      @weather = weather
    end
    
    def name 
      @name
    end
    
    def weather
      @weather
    end
    
  end

  require 'yahoo-weather'

  # Superclass for all weather related questions
  #
  # Initializes globally the weather conditions for all cities so that they get initialized only once
  #
  # * Site with various APIs: http://www.meteorologic.net/donnees-meteo.php
  # * details of Yahoo weather API: http://developer.yahoo.com/weather/
  # * API for synop: http://blogdev.meteorologic.net/index.php?2008/03/19/10-synop-api-d-acces-aux-donnees
  # * Stations list for synop: http://www.uradio.ku.dk/~ct/eurostationer.txt
  # * One can also use yahoo-weather gem (code at https://github.com/shaper/yahoo-weather) 
  class WeatherQuestion < Question

    Sample_yahoo_response = <<-EOS
<?xml version="1.0" encoding="UTF-8" standalone="yes" ?>
<rss version="2.0" xmlns:yweather="http://xml.weather.yahoo.com/ns/rss/1.0" xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#">
<channel>
  <title>Yahoo! Weather - Sunnyvale, CA</title>
  <link>http://us.rd.yahoo.com/dailynews/rss/weather/Sunnyvale__CA/*http://weather.yahoo.com/forecast/USCA1116_f.html</link>
  <description>Yahoo! Weather for Sunnyvale, CA</description>
  <language>en-us</language>
  <lastBuildDate>Fri, 18 Dec 2009 9:38 am PST</lastBuildDate>
  <ttl>60</ttl>
  <yweather:location city="Sunnyvale" region="CA"   country="United States"/>
  <yweather:units temperature="F" distance="mi" pressure="in" speed="mph"/>
  <yweather:wind chill="50"   direction="0"   speed="%d" />
  <yweather:atmosphere humidity="94"  visibility="3"  pressure="%d"  rising="1" />
  <yweather:astronomy sunrise="7:17 am"   sunset="4:52 pm"/>
  <image>
    <title>Yahoo! Weather</title>
    <width>142</width>
    <height>18</height>
    <link>http://weather.yahoo.com</link>
    <url>http://l.yimg.com/a/i/us/nws/th/main_142b.gif</url>
  </image>
  <item>
    <title>Conditions for Sunnyvale, CA at 9:38 am PST</title>
    <geo:lat>37.37</geo:lat>
    <geo:long>-122.04</geo:long>
    <link>http://us.rd.yahoo.com/dailynews/rss/weather/Sunnyvale__CA/*http://weather.yahoo.com/forecast/USCA1116_f.html</link>
    <pubDate>Fri, 18 Dec 2009 9:38 am PST</pubDate>
    <yweather:condition  text="Mostly Cloudy"  code="28"  temp="%d"  date="Fri, 18 Dec 2009 9:38 am PST" />
    <description><![CDATA[
<img src="http://l.yimg.com/a/i/us/we/52/28.gif"/><br />
<b>Current Conditions:</b><br />
Mostly Cloudy, 50 F<BR />
<BR /><b>Forecast:</b><BR />
Fri - Partly Cloudy. High: 62 Low: 49<br />
Sat - Partly Cloudy. High: 65 Low: 49<br />
<br />
<a href="http://us.rd.yahoo.com/dailynews/rss/weather/Sunnyvale__CA/*http://weather.yahoo.com/forecast/USCA1116_f.html">Full Forecast at Yahoo! Weather</a><BR/><BR/>
(provided by <a href="http://www.weather.com" >The Weather Channel</a>)<br/>
]]></description>
    <yweather:forecast day="Fri" date="18 Dec 2009" low="49" high="62" text="Partly Cloudy" code="30" />
    <yweather:forecast day="Sat" date="19 Dec 2009" low="49" high="65" text="Partly Cloudy" code="30" />
    <guid isPermaLink="false">USCA1116_2009_12_18_9_38_PST</guid>
  </item>
</channel>
</rss>
    EOS

    def WeatherQuestion.random_weather
        doc = Nokogiri::XML.parse(Sample_yahoo_response % [ rand * 100.0, 800.0 + (rand * 400.0), rand * 30])
        YahooWeather::Response.new("12345", "http://some.host/", doc)
    end
    
    def WeatherQuestion.weather_of(location)
      begin
        client = YahooWeather::Client.new
        weather = client.lookup_by_woeid(location['code'],'c')
  
        print("weather of %s is %s\n" % [ location['city'], weather.to_s])
      
        Location.new(location['city'],weather)
      rescue => exception
        weather = WeatherQuestion.random_weather
        print("got error %s trying to get weather for %s, setting to random weather %s\n" % [exception, location, weather.to_yaml])
        Location.new(location['city'],weather)
      end        
    end

    # A list of known cities is loaded from the current directory and their current weather 
    # is looked up using Yahoo! Weather service
    # see http://developer.yahoo.com/weather/
    @@weather_in_cities = YAML.load_file(File.join(File.dirname(__FILE__), "locations.yaml"))
                              .map { |location| Location.new(location['city'],nil) }
                              #.map { |location| weather_of(location) } 
              
    def WeatherQuestion.weather_in_cities
      @@weather_in_cities
    end

    # Initializes weather question for a given player
    #
    # +player+:: A +Player+ instance 
    # +location+:: a +City+ object containing name of a location and its current weather (see YahooWeather)
    # If +nil+, a sample city is selected from WeatherQuestion.weather_in_cities
    def initialize(player, location=nil, error_margin = 0.10)
      @error_margin = error_margin
      if location
        @location = location
      else
        @location = WeatherQuestion.weather_in_cities.sample
      end
    end

    # A weather answer may be correct even if not exactly the required weather
    # This question accepts a tolerance of +- 10% around the exact answer with an exponentially decaying 
    # number of points earned for approximate answers.
    #
    # +answer+:: The answer, a string representing a decimal number
    def answered_correctly?(answer)
      answer.to_f > (correct_answer * (1 - @error_margin)) &&
          answer.to_f < (correct_answer * (1 + @error_margin))
    end

    # Score of weather questions follows sigmoid function around the base_points value.
    # 
    # Approximate answers within the error_margin still get exponentially decaying points.
    def points
      ((2 * base_points) / (1 + Math.exp(2 * (correct_answer - answer.to_f).abs))).to_i
    end

    def base_points
      50
    end
  end

  class TemperatureQuestion < WeatherQuestion

    def as_text
      "what is the current (Celsius) temperature in #{@location.name}?"
    end
    
    def correct_answer 
      @location.weather.condition.temp
    end
    
  end

  class PressureQuestion < WeatherQuestion

    def as_text
      "what is the current (Millibar) pressure in #{@location.name}?"
    end

    def correct_answer
      @location.weather.atmosphere.pressure
    end

  end

  class WindQuestion < WeatherQuestion

    def as_text
      "what is the current (kph) speed of wind in #{@location.name}?"
    end

    def correct_answer
      @location.weather.wind.speed
    end

  end

  # Some notes for geolocation questions
  #
  # * http://www.ncolomer.net/2011/06/use-openstreetmap-web-api/
  # * http://services.gisgraphy.com/public/geocoding_worldwide.html
  # * http://www.gisgraphy.com/documentation/user-guide.htm#geocodingservice
  # * https://github.com/homelight/ruby-geocoder
  
  class QuestionFactory
    attr_reader :round

    def initialize(profile = nil)
      @round = 1
      if profile.nil? 
      @question_types = [
        AdditionQuestion,
        MaximumQuestion,
        MultiplicationQuestion,
        SquareCubeQuestion,
        GeneralKnowledgeQuestion,
        PrimesQuestion,
        PlusQuestion,
        SubtractionQuestion,
        FibonacciQuestion,
        PowerQuestion,
        MinusQuestion,
#          TemperatureQuestion,
        AdditionAdditionQuestion,
        MultQuestion,
        AdditionMultiplicationQuestion,
#          PressureQuestion,
        AnagramQuestion,
        GeneralArithmeticQuestion,
#          WindQuestion,
        ScrabbleQuestion
      ]
      else
        File.open(profile,'r') do |file|
          @question_types = load_profile(file)
        end
    end
    end

    def next_question(player)
      window_end = (@round * 2 - 1)
      window_start = [0, window_end - 4].max
      available_question_types = @question_types[window_start..window_end]
      available_question_types.sample.new(player)
    end

    def advance_round
      @round += 1
    end

    def save_profile (stream = nil)
      if stream.nil?
        stream = File.open("question_factory.yaml", "w")
      end

      stream.write(@question_types.to_yaml)
    ensure
      stream.close
    end

    def load_profile (stream)
      YAML.load(stream)
    end

  end

  class WarmupQuestion < Question
    def initialize(player)
      @player = player
    end

    def correct_answer
      @player.name
    end

    def as_text
      "what is your name"
    end
  end

  class WarmupQuestionFactory
    def next_question(player)
      WarmupQuestion.new(player)
    end

    def advance_round
      raise("please just restart the server")
    end
  end

end
