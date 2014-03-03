class NotesController < ApplicationController
  before_action :require_login

  def index
  end

  def create
    @note = current_user.notes.new(note_params)
    if @note.save
      redirect_to @note
    else
      render 'new'
    end
  end

  def new
    @note = current_user.notes.new
  end

  def edit
    find_note_by_id
  end

  def show
    find_note_by_id
  end

  def update
    @note = current_user.notes.find(params[:id])
    if @note.update(note_params)
      redirect_to @note
    else
      render 'edit'
    end
  end

  def destroy
    @note = current_user.notes.find(params[:id])
    @note.destroy
    redirect_to notes_path
  end

  private
    def note_params
      params.require(:note).permit(:title, :text)
    end

    def find_note_by_id
      begin
        @note = current_user.notes.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        flash[:danger] = t :notfound
        redirect_to notes_path
      end
    end
end
