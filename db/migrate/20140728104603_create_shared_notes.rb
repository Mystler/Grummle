class CreateSharedNotes < ActiveRecord::Migration
  def change
    create_table :shared_notes do |t|
      t.references :note, index: true
      t.references :user, index: true
      t.timestamps
    end
  end
end
