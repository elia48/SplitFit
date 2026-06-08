class MessagesController < ApplicationController
  skip_after_action :verify_policy_scoped, only: :index
  before_action :set_training, only: [:index, :create]

  def index
    if @training
      authorize @training, :access_chat?
      @messages = @training.messages.includes(:user).order(:created_at)
      @message = Message.new
      render :show
    else
      @chats = current_user.accessible_chat_trainings
      @private_chats = current_user.private_chats
                                   .includes(:sender, :recipient, :private_messages)
                                   .order(updated_at: :desc)
    end
  end

  def create
    @message = @training.messages.new(message_params)
    @message.user = current_user
    authorize @message

    if @message.save
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "new_message_form",
            partial: "messages/form",
            locals: { message: Message.new, training: @training }
          )
        end
        format.html { redirect_to training_messages_path(@training) }
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "new_message_form",
            partial: "messages/form",
            locals: { message: @message, training: @training }
          )
        end
        format.html { redirect_to training_messages_path(@training), alert: "Could not send message." }
      end
    end
  end

  private

  def set_training
    @training = Training.find(params[:training_id]) if params[:training_id]
  end

  def message_params
    params.require(:message).permit(:content)
  end
end
