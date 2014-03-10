class ChangeNotesPublic < ActiveRecord::Migration
  def change
    reversible do |dir|
      change_table :notes do |t|
        dir.up   { t.change :public, :boolean, null: nil, default: nil }
        dir.down { t.change :public, :boolean, null: false, default: false }
      end
    end
  end
end
