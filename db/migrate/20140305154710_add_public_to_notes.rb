class AddPublicToNotes < ActiveRecord::Migration
  def change
    add_column :notes, :public, :boolean, null: false, default: false
  end
end
