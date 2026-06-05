class ReviewsController < ApplicationController
  def create
    @training = Training.find(params[:training_id])
    @review = Review.new(review_params)
    @review.user = current_user
    @review.training = @training
    @review.coach = @training.user
    authorize @review
      # 7. save
      # 8. redirect/render
    
  end

  private

  def review_params
    params.require(:review).permit(:score, :description)
  end

end
