require 'spec_helper'
require 'extreme_startup/question_factory'
require 'extreme_startup/questions/webshop_conversation'

module ExtremeStartup::Questions
  describe WebshopQuestion do
    
    context "client doesn't know what the player can offer" do
      let(:conversation) { WebshopConversation.new }

      it "should start by asking for products" do
        conversation.question.should == "what products do you have for sale (comma separated)"
      end
      
      it "should award one point per product" do
        conversation.add_answer("red balloon, green balloon, blue balloon")
        conversation.score.should == 3
      end

      it "should start with empty shopping cart" do
        conversation.add_answer("red balloon, green balloon, blue balloon")
        conversation.shopping_cart_count_for("red_balloon").should be_nil        
      end
    end
    
    context "client knows the product list" do
      # TODO: There must be a better way of doing this
      let(:conversation) do
        result = WebshopConversation.new({"red balloon" => nil, "blue balloon" => nil})
        result.question
        result
      end
      
      it "should ask for the price of a product" do
        conversation.question.should =~
          /how many dollars does one (red|green|blue) balloon cost/
      end
      
      it "should accept a numeric answer" do
        conversation.add_answer "13.01"
        conversation.score.should > 0
      end
      
      it "should remember a price" do
        conversation.question =~
          /how many dollars does one ((red|green|blue) balloon) cost/
        conversation.add_answer "12.99"
        conversation.price_for($1).should == 12.99
      end
      
      it "should reject a non-numeric answer" do
        conversation.add_answer "two dollars"
        conversation.score.should < 0
      end
      
      it "should kill clients who didn't get an answer" do
        conversation.add_answer "two dollars"
        conversation.dead?.should be_true
      end
    end
    
    context "client knows product prices" do
      let(:conversation) do
        products = {"red balloon" => 12.0, "blue balloon" => 10.0}
        WebshopConversation.new(products)
      end
      
      it "should put items in shopping cart" do
        conversation.question.should =~ /please put \d+ (red|blue) balloon in my shopping cart/
      end
      
      it "should accept any answer" do
        conversation.question
        conversation.add_answer "okie dokie"
        conversation.score.should > 0
      end
      
      it "remembers what it bought" do
        conversation.question =~ /put (\d+) (red balloon|blue balloon)/
        conversation.add_answer "okay"
        conversation.shopping_cart_count_for($2).should == $1.to_i
      end
    end
    
    context "client is through shopping" do
      let(:conversation) do
        products = {"red balloon" => 12.0, "blue balloon" => 10.0}
        cart = {"red balloon" => 4, "blue balloon" => 8}
        WebshopConversation.new(products, cart)
      end
      
      it "asks for total" do
        conversation.question.should == "what is my order total"
      end
      
      it "accepts correct total" do
        conversation.question
        conversation.add_answer((12*4 + 10*8).to_s)
        conversation.score.should > 0
      end
      
      it "rejects incorrect total" do
        conversation.question
        conversation.add_answer("10")
        conversation.score.should < 0
      end
      
      it "ends session when it gets correct total" do
        conversation.question
        conversation.add_answer((12*4 + 10*8).to_s)
        conversation.dead?.should be_true        
      end
    end
  end
end

