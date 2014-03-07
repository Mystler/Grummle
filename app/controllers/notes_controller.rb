class NotesController < ApplicationController
  before_action :require_login, except: :show

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
    @note = current_user.notes.find_by_permalink!(params[:id])
  end

  def show
    @note = Note.find_by_permalink(params[:id])
    if @note
      unless @note.public
        require_login
        unless @note.user_id == current_user.id
          flash[:danger] = t :notfound
          redirect_to notes_path
        end
      end
    else
      flash[:danger] = t :notfound
      redirect_to notes_path
    end
  end

  def update
    @note = current_user.notes.find_by_permalink!(params[:id])
    if @note.update(note_params)
      redirect_to @note
    else
      render 'edit'
    end
  end

  def destroy
    @note = current_user.notes.find_by_permalink!(params[:id])
    @note.destroy
    redirect_to notes_path
  end

  private
    def note_params
      params.require(:note).permit(:title, :text, :public)
    end
end
