class AddUpdateTokenToUsers < ActiveRecord::Migration
  def change
    add_column :users, :update_token, :string
    add_index :users, :update_token
    remove_column :users, :auth_token_created, :datetime

    reversible do |dir|
      dir.up do
        User.all.each do |user|
          user.save! # generates new tokens
        end
      end
    end
  end
end
