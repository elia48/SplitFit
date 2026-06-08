class PrivateChatsController < ApplicationController
  def show
    @private_chat = PrivateChat.find(params[:id])
    authorize @private_chat
    @messages = @private_chat.private_messages.includes(:user).order(:created_at)
    @new_message = PrivateMessage.new
    @other_user = @private_chat.other_participant(current_user)
  end

  def create
    recipient = User.find(params[:recipient_id])
    redirect_to(messages_path) and return if recipient == current_user

    @private_chat = PrivateChat.between(current_user, recipient) ||
                    PrivateChat.new(sender: current_user, recipient: recipient)
    authorize @private_chat
    @private_chat.save! unless @private_chat.persisted?
    redirect_to @private_chat
  end
end
