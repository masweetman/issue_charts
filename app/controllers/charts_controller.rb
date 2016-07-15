class ChartsController < ApplicationController
  unloadable

  def index
    @project = Project.find(params[:project_id])
    @my_charts = Chart.where('project_id = ? AND user_id = ? AND public = false', @project.id, User.current.id).order(:name)
    @public_charts = Chart.where('project_id = ? AND public = true', @project.id).order(:name)
    if !User.current.allowed_to?(:view_charts, @project)
      render_404
    end
  end

  def show
    session[:return_to] = request.referer
    @chart = Chart.find(params[:id])
    @project = Project.find(@chart.project_id)
    if !User.current.allowed_to?(:view_charts, @project)
      render_404
    end
  end

  def new
    session[:chart_params] ||= {}
    @project = Project.find(params[:project_id])
    @chart = Chart.new(session[:chart_params])
    @chart.current_step = session[:chart_step]
    if !(User.current.allowed_to?(:create_charts, @project) || User.current.allowed_to?(:create_public_charts, @project))
      render_404
    end
  end

  def create
    session[:chart_params].deep_merge!(params[:chart]) if params[:chart]
    @chart = Chart.new(session[:chart_params])
    @project = Project.find(@chart.project_id)
    @chart.current_step = session[:chart_step]
    if @chart.last_step?
      @chart.save
    else
      @chart.next_step
    end
    session[:chart_step] = @chart.current_step

    if @chart.new_record?
      render 'new'
    else
      session.delete(:chart_step)
      session.delete(:chart_params)
      redirect_to @chart
    end
  end

  def edit
    @chart = Chart.find(params[:id])
    @project = Project.find(@chart.project_id)
    if !(User.current.allowed_to?(:edit_charts, @project) || User.current.allowed_to?(:edit_public_charts, @project))
      render_404
    end
  end

  def update
    @chart = Chart.find(params[:id])
    @project = Project.find(@chart.project_id)
    if @chart.update_attributes(chart_params)
      redirect_to session.delete(:return_to)
      flash[:notice] = l(:notice_successful_update)
    else
      render 'edit'
    end
  end

  def destroy
    @chart = Chart.find(params[:id])
    @project = Project.find(@chart.project_id)
    @chart.destroy
    redirect_to session.delete(:return_to)
    flash[:notice] = l(:notice_successful_delete)
    if !(User.current.allowed_to?(:edit_charts, @project) || User.current.allowed_to?(:edit_public_charts, @project))
      render_404
    end
  end

  private

    def chart_params
      params.require(:chart).permit(:project_id, :name, :tracker_id, :chart_type, :group_by_field, :user_id, :public, :range_integer, :range_type)
    end

end
