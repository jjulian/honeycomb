class AddAuthlogicFieldsToPeople < ActiveRecord::Migration
  def self.up
    add_column :people,    :crypted_password,    :string
    add_column :people,    :password_salt,       :string
    add_column :people,    :persistence_token,   :string
    add_column :people,    :perishable_token,    :string
    add_column :people,    :login_count,         :integer
    add_column :people,    :failed_login_count,  :integer
    add_column :people,    :last_request_at,     :datetime
    add_column :people,    :current_login_at,    :datetime
    add_column :people,    :last_login_at,       :datetime
    add_column :people,    :current_login_ip,    :string
    add_column :people,    :last_login_ip,       :string
  end

  def self.down
    remove_column :people,    :crypted_password
    remove_column :people,    :password_salt
    remove_column :people,    :persistence_token
    remove_column :people,    :perishable_token
    remove_column :people,    :login_count
    remove_column :people,    :failed_login_count
    remove_column :people,    :last_request_at
    remove_column :people,    :current_login_at
    remove_column :people,    :last_login_at
    remove_column :people,    :current_login_ip
    remove_column :people,    :last_login_ip
  end
end
