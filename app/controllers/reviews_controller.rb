class ReviewsController < ApplicationController
  def create
    @training = Training.find(params[:training_id])
    @review = Review.new(review_params)
    @review.user = current_user
    @review.training = @training
    @review.coach = @training.user
    if @review.coach.nil?
      redirect_to training_path(@training), alert: "Cannot create a review without a coach."
      return
    end
    authorize @review
    if @review.save
      redirect_to training_path(@training), notice: "Review created"
    else
      @coach = @training.user
      render "trainings/show", status: :unprocessable_entity
    end
  end

  private

  def review_params
    params.require(:review).permit(:score, :description)
  end

end
