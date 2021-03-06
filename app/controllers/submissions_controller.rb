class SubmissionsController < ApplicationController
  include CommentsHelper
  include ApplicationHelper
  before_filter :set_submission, only: [:destroy, :edit, :update, :download, :favorite]
  before_filter :authenticate_user!, only: [:destroy, :edit, :create, :new, :update, :favorite]
  before_filter :require_admin, only: [:favorite]
  def index
    category = params[:category]
    subcategory = params[:subcategory]
    @sort = params[:sort]
    @time = params[:time]
    @submissions = Submission.where('approved_at IS NOT NULL')
    @sort_options = {
      'Newest' => 'newest',
      'Oldest' => 'oldest',
      'Popular' => 'downloads',
      'Most Liked' => 'likes'
    }
    @time_options = {
      'Now' => 'today', 
      'This Week' => 'week',
      'This Month' => 'month',
      'All Time' => 'all'
    }
    if category
      @submissions = @submissions.where(:category => category)
      @subcategories = CATEGORIES[category.to_sym] || nil
    end
    if subcategory && subcategory != 'all'
      @submissions = @submissions.where(:sub_category => subcategory)
    end
    if @sort
      @submissions = reg_sort(@sort, @submissions) 
    end
    if @time && @time != 'all'
      @submissions = time_sort(@time, @submissions)
    end
    @submissions = @submissions.page(params[:page]).per(21)
    @sort = @sort_options.key(@sort) || @sort_options.keys[0]
    @time = @time_options.key(@time) || @time_options.keys[0]
  end

  def favorite
     @submission.favorite
     redirect_to @submission, alert: t('favorite.successfully_favorited', name: @submission.name)
  end

  def show
    @submission = Submission.find(params[:id])
    @sort_options = {
      'Oldest First' => 'oldest',
      'Newest First' => 'newest',
      'Most Liked' => 'liked',
      'Creator Only' => 'creator',
      'Admin Only' => 'admin'
    }
    @sort = params[:c_sort] ||= session['c_sort'] ||= @sort_options.values[0]
    session['c_sort'] = @sort
    @comments = comment_sort(@submission.comments).page(params[:c_page]).per(12).reject(&:new_record?)
    @rating = nil
    if current_user
      if @submission.has_liked(current_user)
        return @rating = 'like'
      elsif @submission.has_disliked(current_user)
        @rating = 'dislike'
      end
    end
  end

  def like
    return render json: { :status => "not authenticated"} if !current_user
    set_submission
    return render json: { :status => "can not rate own content" } if current_user == @submission.creator
    current_like = @submission.likes.where(:user => current_user).first
    if current_like
      current_like.destroy
      @submission.like_count -= 1
      @submission.update_rating
      respond_to do |format|
        format.json { render json: { :status => 'removed like', :count => @submission.avg_rating }, status: 200 }
      end
    else
      current_dislike = @submission.dislikes.where(:user => current_user).first
      if current_dislike
        @submission.dislike_count -= 1
        current_dislike.destroy
      end
      @submission.likes.create(:user => current_user)
      @submission.like_count += 1
      @submission.update_rating
      respond_to do |format|
        format.json { render json: { :status => 'liked submission', :count => @submission.avg_rating }, status: 200 }
      end
    end
  end

  def dislike
    return render json: { :status => "not authenticated"} if !current_user
    set_submission
    return render json: { :status => "can not rate own content" } if current_user == @submission.creator
    current_dislike = @submission.dislikes.where(:user => current_user).first
    if current_dislike
      current_dislike.destroy
      @submission.dislike_count -= 1
      @submission.update_rating
      respond_to do |format|
        format.json { render json: { :status => 'removed dislike', :count => @submission.avg_rating }, status: 200 }
      end
    else
      current_like = @submission.likes.where(:user => current_user).first
      if current_like
        @submission.like_count -= 1
        current_like.destroy
      end
      @submission.dislikes.create(:user => current_user)
      @submission.dislike_count += 1
      @submission.update_rating
      respond_to do |format|
        format.json { render json: { :status => 'disliked submission', :count => @submission.avg_rating }, status: 200 }
      end
    end
  end

  def download
    latest = @submission.latest
    return if !latest
    @submission.downloads.create(:ip_address => get_request_ip)
    send_file latest.upload.path
  end

  def destroy
    return redirect_to root_path, :alert => t('database.no_permission') unless @submission.can_manage(current_user)
    @submission.destroy
    redirect_to submissions_path, :notice => t('submissions.successfully_deleted')
  end

  def new
    @submission = Submission.new
  end

  def edit
    return redirect_to root_path, :alert => t('database.no_permission') unless @submission.can_manage(current_user)
  end

  def create
    @submission = Submission.new(submission_params)
    @submission.creator = current_user
    if @submission.save
      redirect_to @submission, :notice => t('submissions.successfully_created')
    else
      render 'edit', :alert => t('submissions.failed_save')
    end
  end

  def update
    if @submission.update_attributes(submission_params)
      return redirect_to @submission, :notice => t('database.successfully_saved_changes')
    else
      render 'edit'
    end
  end

  private
  def set_submission
    @submission = Submission.find(params[:id] ||= params[:submission_id])
  end

  def submission_params
    params.require(:submission).permit(:body, :name, :category, :sub_category)
  end

  def time_sort(timeframe, submissions)
    case timeframe.downcase
    when 'today'
      submissions.where('approved_at >= ?', DateTime.now - 24.hours)
    when 'week'
      submissions.where('approved_at >= ?', DateTime.now - 7.days)
    when 'month'
      submissions.where('approved_at >= ?', DateTime.now - 1.month)
    else
      submissions
    end
  end

  def reg_sort(sort, submissions)
    case sort.downcase
    when 'newest'
      submissions.order('approved_at DESC')
    when 'oldest'
      submissions.order('approved_at ASC')
    when 'downloads'
      submissions.order('download_count DESC')
    when 'likes'
      submissions.order('avg_rating DESC')
    else
      submissions
    end
  end
end
