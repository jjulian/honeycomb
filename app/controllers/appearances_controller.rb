class AppearancesController < ApplicationController
  
  def index
    @appearances = Appearance.current.scoped(:include => {:device => :person})
  end
  
end
