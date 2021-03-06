class Device < ActiveRecord::Base
  belongs_to :person
  has_many :appearances, :order => 'first_seen_at'
  has_one :manufacturer, :foreign_key => 'mac_identifier', :primary_key => :manufacturer_id
  #has_one :current_appearance, :primary_key => 'appearance_id'
  
  def manufacturer_id
    mac[0..7]
  end

  def image
    person ? person.gravatar_url : '/images/unknown_user.jpg'
  end
  
  def assign(email)
    person = Person.find_by_email(email)
    unless person
      person = Person.new({:email => email})
      person.save_without_session_maintenance
    end
    self.update_attribute(:person_id, person.id)
    PersonMailer.deliver_confirmation(self)
  end
  
  def confirmation_key
    Digest::MD5.hexdigest("#{mac}#{id}#{person.email}")
  end
end
