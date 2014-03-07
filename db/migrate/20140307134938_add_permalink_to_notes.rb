class AddPermalinkToNotes < ActiveRecord::Migration
  def change
    add_column :notes, :permalink, :string
    add_index :notes, :permalink

    reversible do |dir|
      dir.up do
        Note.all.each do |note|
          note.generate_permalink
          note.save!
        end
      end
    end
  end
end
