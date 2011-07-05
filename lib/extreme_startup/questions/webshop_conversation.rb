module ExtremeStartup::Questions
  include ExtremeStartup

  class WebshopConversation < Conversation
    def initialize(product_list = nil, shopping_cart = {})
      @product_list = product_list
      @shopping_cart = shopping_cart
    end
    
    def dead?
      not answered_correctly? or @asked_for_total
    end
    
    def question
      @queried_product = @purchased_product = @asked_for_total = nil
      if !@product_list
        "what products do you have for sale (comma separated)"
      elsif ready_to_shop?
        @queried_product = @product_list.keys.pick_one
        "how many dollars does one #{@queried_product} cost"
      elsif still_shopping?
        @purchased_product = @product_list.keys.pick_one
        @purchased_amount = rand(20)
        "please put #{@purchased_amount} #{@purchased_product} in my shopping cart"
      else
        @asked_for_total = true
        "what is my order total"
      end
    end
    
    def still_shopping?
      for product in @product_list.keys
        return product if not @shopping_cart[product]
      end
      return false
    end
    
    def ready_to_shop?
      @product_list.has_value?(nil)
    end
    
    def add_answer(answer)
      if not @product_list
        @product_list = {} 
        answer.split(",").each { |p| @product_list[p.strip] = nil }
      elsif @queried_product
        @price = Float(answer) rescue nil
        @product_list[@queried_product] = @price
      elsif @purchased_product
        @shopping_cart[@purchased_product] = @purchased_amount
      end
      @answer = answer
    end
    
    def price_for(product)
      @product_list[product]
    end
    
    def order_total
      total = 0
      for product in @product_list.keys
        total += @shopping_cart[product] * price_for(product)
      end      
      total
    end
    
    def answered_correctly?
      if @queried_product
        return @price
      elsif @asked_for_total
        return (Float(@answer.strip) rescue nil) == order_total
      end
      true
    end
    
    def shopping_cart_count_for(product)
      @shopping_cart[product]
    end

    def points
      @answer.split(",").length
    end
  end
  
  class WebshopQuestion < ConversationalQuestion
    def create_session
      WebshopConversation.new
    end    

    def spawn?(sessions, spawn_rate)
      return true if sessions.empty?
      return false if sessions.length > 3
      (rand(100) < spawn_rate)
    end
  end
end
