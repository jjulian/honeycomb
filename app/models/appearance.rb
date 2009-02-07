class Appearance < ActiveRecord::Base
  has_many :people, :through => :devices
  belongs_to :device
  
  validates_presence_of :device_id
  
  after_save { |record| record.device.update_attribute(:appearance_id, record.id) }
  
  named_scope :current, :conditions => ['created_at >= ? AND updated_at > NOW() - INTERVAL 5 MINUTE', Time.today]
  named_scope :today, :conditions => ['created_at >= ?', Time.today]

  def self.parse(line)
    # Feb  6 15:17:58 honey dhcpd: DHCPACK on 192.168.1.109 to 00:16:cb:be:b0:ac (Michael-Brenner-MBP) via eth0
    appeared_at, ip, mac, name = line.match(/^(.*?) honey dhcpd: DHCPACK on ([\d\.]+) to ([\w\:]+)\s?\(?(.*?)\)? via/).captures
    
    device = Device.find_by_mac(mac) || Device.create(:mac => mac, :name => name)
    if appearance = today.find_by_device_id(device)
      appearance.update_attribute(:ip_address, ip)
      device.update_attribute(:name, name)
    else
      appearance = device.appearances.create(:created_at => Time.parse(appeared_at), :ip_address => ip)
    end
    appearance
  end

  def image
    device.image
  end
  
  def show_name
    device.person ? device.person.show_name : 'Unidentified User'
  end
end