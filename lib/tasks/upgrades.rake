namespace :upgrades do
  desc "Update character boolean columns in SQLite3 to 1/0"
  task sqliteboolean: :environment do
    Note.where("public = 't'").update_all(public: 1)
    User.where("activated = 't'").update_all(activated: 1)
    Note.where("public = 'f'").update_all(public: 0)
    User.where("activated = 'f'").update_all(activated: 0)
  end
end
