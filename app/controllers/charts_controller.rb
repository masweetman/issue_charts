class ChartsController < ApplicationController
  unloadable

  def index
    @project = Project.find(params[:project_id])
  	@charts = Chart.where(:project_id => @project.id).order(:name)
  end

  def show
    session[:return_to] = request.referer
    @chart = Chart.find(params[:id])
    @project = Project.find(@chart.project_id)
  end

  def new
    @project = Project.find(params[:project_id])
    session[:chart_params] ||= {}
    @chart = Chart.new(session[:chart_params])
    @chart.current_step = session[:chart_step]
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
    session[:chart_params] ||= {}
    @chart = Chart.find(params[:id])
    @project = Project.find(@chart.project_id)
  end

  def update
    @chart = Chart.find(params[:id])
    if @chart.update_attributes(chart_params)
      redirect_to session.delete(:return_to)
      flash[:notice] = l(:notice_successful_update)
    else
      render 'edit'
    end
  end

  def destroy
    @chart = Chart.find(params[:id])
    @chart.destroy
    redirect_to session.delete(:return_to)
    flash[:notice] = l(:notice_successful_delete)
  end

  def tracker_custom_fields(tracker_id)
    Tracker.find(tracker_id).custom_fields.order(:name)
  end

  private

    def chart_params
      params.require(:chart).permit(:project_id, :name, :tracker_id, :chart_type, :group_by_field, :user_id)
    end

end
