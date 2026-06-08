class PrivateMessagesController < ApplicationController
  def create
    @private_chat = PrivateChat.find(params[:private_chat_id])
    authorize @private_chat, :show?
    @message = @private_chat.private_messages.build(
      user: current_user,
      content: params[:private_message][:content]
    )

    if @message.save
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "new_private_message_form",
            partial: "private_messages/form",
            locals: { private_message: PrivateMessage.new, private_chat: @private_chat }
          )
        end
        format.html { redirect_to @private_chat }
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "new_private_message_form",
            partial: "private_messages/form",
            locals: { private_message: @message, private_chat: @private_chat }
          )
        end
        format.html { redirect_to @private_chat, alert: "Could not send message." }
      end
    end
  end
end
