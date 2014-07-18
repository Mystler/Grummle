class AddActivatedToUser < ActiveRecord::Migration
  def change
    add_column :users, :activated, :boolean

    reversible do |dir|
      dir.up do
        User.update_all activated: true
      end
    end
  end
end
