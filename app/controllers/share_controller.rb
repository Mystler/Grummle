class ShareController < ApplicationController
  before_action :require_note_owner

  def index
  end

  def create
    user = User.find_by_username(params[:username])
    if user && user.id != current_user.id && !@note.shares.find_by_user_id(user.id)
      share = @note.shares.new(user_id: user.id)
      share.save!
      ShareMailer.note_shared_email(@note, user).deliver_now
      flash_message :success, t(:noteshared)
    else
      flash_message :danger, t(:sharingfailed)
    end
    redirect_to note_share_index_path
  end

  def destroy
    share = @note.shares.find_by_id!(params[:id])
    share.destroy!
    redirect_to note_share_index_path
  end

  private
    def require_note_owner
      require_login
      return unless current_user
      @note = current_user.notes.find_by_permalink(params[:note_id])
      unless @note
        flash_message :danger, t(:nopermission)
        redirect_to notes_path
      end
    end
end
