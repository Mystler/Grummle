require 'test_helper'

class NoteTest < ActiveSupport::TestCase
  test 'requires data' do
    note = Note.new
    assert !note.save, "Saved note without data"
  end

  test 'title must be at least 4 characters long' do
    note = Note.new(title: '123', text: 'Blah')
    assert !note.save, 'Saved note with less than 4 characters in the title'
    note = Note.new(title: '1234', text: 'Blah')
    assert note.save, 'Could not save note although title was 4 characters long'
  end
end
