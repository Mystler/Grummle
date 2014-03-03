require 'test_helper'

class NotesControllerTest < ActionController::TestCase
  test 'redirect on record not found' do
    do_login
    get :show, id: '123456'
    assert_redirected_to notes_path(assigns(:flash), locale: :en), 'Note not found does not redirect'
    get :edit, id: '123456'
    assert_redirected_to notes_path(assigns(:flash), locale: :en), 'Note not found does not redirect'
    do_logout
  end

  test 'creation works' do
    do_login
    assert_difference('Note.count') do
      post :create, note: {title: '12345', text: 'Blah'}
    end
    assert_redirected_to note_path(assigns(:note))
    do_logout
  end

  test 'update works' do
    do_login
    patch :update, id: notes(:testnote).id, note: {title: 'Updated', text: 'Blah'}
    assert_redirected_to note_path(assigns(:note))
    assert User.find(users(:testuser).id).notes.find(notes(:testnote).id).title == 'Updated', 'Note was not updated correctly'
    do_logout
  end

  test 'markdown displayed' do
    do_login
    get :show, id: notes(:markupnote).id
    assert_select 'div.panel-body em, div.panel-body i', 'Dolor', 'Markup not rendered correctly'
    do_logout
  end

  test 'access restricted' do
    do_login
    assert_raises(ActiveRecord::RecordNotFound) do
      User.find(users(:testuser).id).notes.find(notes(:userless).id)
    end
    do_logout
  end
end
