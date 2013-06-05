require 'spec_helper'
require 'extreme_startup/question_factory'
require 'extreme_startup/player'


module ExtremeStartup

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
  <yweather:wind chill="50"   direction="0"   speed="10" />
  <yweather:atmosphere humidity="94"  visibility="3"  pressure="30.27"  rising="1" />
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
    <yweather:condition  text="Mostly Cloudy"  code="28"  temp="50"  date="Fri, 18 Dec 2009 9:38 am PST" />
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

  describe TemperatureQuestion do
    let(:question) { TemperatureQuestion.new(Player.new) }

    let(:sample_weather_data) {     
      doc = Nokogiri::XML.parse(Sample_yahoo_response)
      YahooWeather::Response.new("12345", "http://some.host/", doc)
    }
    
    it "converts to a string" do
      question.as_text.should =~ /what is the current \(Celsius\) temperature in .+\?/i
    end

    context "when temperature is known" do
      let(:question) { TemperatureQuestion.new(Player.new, Location.new("Tours",sample_weather_data)) }
      
      it "identifies '50' as correct (exact) answer" do
        question.answered_correctly?("50").should be_true        
      end

      it "identifies '48' as correct (lower approximate) answer" do
        question.answered_correctly?("48").should be_true
      end

      it "rejects '53' as incorrect (over upper bound approximate) answer" do
        question.answered_correctly?("56").should be_false
      end
    end

    context "when temperature is known and player has answered" do
      let(:question) { TemperatureQuestion.new(Player.new, Location.new("Tours",sample_weather_data)) }

      it "credit 50 points for exact answer" do
        question.answer = "50"
        question.points.should == 50
      end

      it "credit less than 50 points for approximate lower bound correct answer" do
        question.answer = "48"
        question.points.should < 50
      end

      it "credit less than 50 points for approximate upper bound correct answer" do
        question.answer = "53"
        question.points.should < 50
      end

    end
  end

  describe PressureQuestion do
    let(:question) { PressureQuestion.new(Player.new) }

    let(:sample_weather_data) {
      doc = Nokogiri::XML.parse(Sample_yahoo_response)
      YahooWeather::Response.new("12345", "http://some.host/", doc)
    }

    it "converts to a string" do
      question.as_text.should =~ /what is the current \(Millibar\) pressure in .+\?/i
    end

    context "when pressure is known and player has answered" do
      let(:question) { PressureQuestion.new(Player.new, Location.new("Tours",sample_weather_data)) }

      it "credit 50 points for exact answer" do
        question.answer = "30.27"
        question.points.should == 50
      end

      it "credit less than 50 points for approximate lower bound correct answer" do
        question.answer = "28"
        question.points.should < 50
      end

      it "credit less than 50 points for approximate upper bound correct answer" do
        question.answer = "32"
        question.points.should < 50
      end

    end

  end

  describe WindQuestion do
    let(:question) { WindQuestion.new(Player.new) }

    let(:sample_weather_data) {
      doc = Nokogiri::XML.parse(Sample_yahoo_response)
      YahooWeather::Response.new("12345", "http://some.host/", doc)
    }

    it "converts to a string" do
      question.as_text.should =~ /what is the current \(kph\) speed of wind in .+\?/i
    end

    context "when wind speed is known and player has answered" do
      let(:question) { WindQuestion.new(Player.new, Location.new("Tours",sample_weather_data)) }

      it "credit 50 points for exact answer" do
        question.answer = "10"
        question.points.should == 50
      end

      it "credit less than 50 points for approximate upper bound correct answer" do
        question.answer = "9.5"
        question.points.should < 50
      end

    end

  end

end