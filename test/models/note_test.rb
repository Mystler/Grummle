require 'test_helper'

class NoteTest < ActiveSupport::TestCase
  test 'requires data' do
    note = Note.new
    assert !note.save, "Saved note without data"
  end

  test 'title must be at least 5 characters long' do
    note = Note.new(title: '1234', text: 'Blah')
    assert !note.save, 'Saved note with less than 5 characters in the title'
    note = Note.new(title: '12345', text: 'Blah')
    assert note.save, 'Could not save note although title was 5 characters long'
  end
end
