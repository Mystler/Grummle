class CreateShares < ActiveRecord::Migration
  def change
    create_table :shares do |t|
      t.references :note, index: true
      t.references :user, index: true
    end
  end
end
