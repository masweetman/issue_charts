include ChartsHelper

class ChartsController < ApplicationController
  unloadable

  def index
    @project = Project.find(params[:project_id])
    if !User.current.allowed_to?(:view_charts, @project)
      render_404
    else
      @my_charts = Chart.where('project_id = ? AND user_id = ? AND is_public = false', @project.id, User.current.id).order(:name)
      @public_charts = Chart.where('project_id = ? AND is_public = true', @project.id).order(:name)
    end
  end

  def show
    @chart = Chart.find(params[:id])
    @project = Project.find(@chart.project_id)
    if !User.current.allowed_to?(:view_charts, @project)
      render_404
    end
  end

  def set_options
    @chart_type_options = { l(:label_line_chart) => 'Line',
      l(:label_pie_chart) => 'Pie',
      l(:label_column_chart) => 'Column',
      l(:label_bar_chart) => 'Bar',
      l(:label_area_chart) => 'Area'}.merge(predefined_types)
    
    @tracker_options = { l(:label_tracker_all) => 0 }
    @project.trackers.order(:name).map{ |t| @tracker_options[t.name] = t.id.to_s }
    
    @range_type_options = { l(:label_day_plural) => 'days', l(:label_month_plural) => 'months', l(:label_year_plural) => 'years' }
    
    if !predefined_types.values.include?(params[:chart_type])
      @issue_status_options = { l(:label_open_issues_plural) => 'o', l(:label_closed_issues_plural) => 'c', l(:label_total) => '*' }
      @time_options = { l(:field_estimated_hours) => 'estimated_hours', l(:label_spent_time) => 'spent_hours' }
    end

    unless params[:chart_type].to_s.empty? || predefined_types.values.include?(params[:chart_type])
      options = standard_fields
      if params[:time] == 'spent_hours'
        options.delete(l(:field_created_on))
      end
      @group_by_field_options = { l(:field_tracker) => 'tracker' }.merge(options) if (params[:tracker_id] == '0' || !params[:time].to_s.empty?)
      @group_by_field_options = group_by_field_options(params[:tracker_id]) unless (params[:tracker_id] == '' || params[:tracker_id] == '0' || !params[:time].to_s.empty?)
    end
  end

  def update_edit_options
    @chart = Chart.find(params[:id])
    @project = Project.find(@chart.project_id)
    params[:name] ||= @chart.name
    params[:tracker_id] ||= @chart.tracker_id.to_s
    params[:chart_type] ||= @chart.chart_type
    params[:group_by_field] ||= @chart.group_by_field
    params[:is_public] ||= @chart.is_public.to_s
    params[:range_integer] ||= @chart.range_integer.to_s
    params[:range_type] ||= @chart.range_type
    params[:time] ||= @chart.time
    params[:issue_status] ||= @chart.issue_status

    set_options
    
    respond_to do |format|
      format.js
    end
  end

  def update_options
    @project = Project.find(params[:project_id])
    @chart = Chart.new

    set_options
    
    respond_to do |format|
      format.js
    end
  end
  
  def new
    @project = Project.find(params[:project_id])
    if !(User.current.allowed_to?(:create_charts, @project) || User.current.allowed_to?(:create_public_charts, @project))
      render_404
    else
      @chart = Chart.new
    end

    @chart_type_options = { l(:label_line_chart) => 'Line',
      l(:label_pie_chart) => 'Pie',
      l(:label_column_chart) => 'Column',
      l(:label_bar_chart) => 'Bar',
      l(:label_area_chart) => 'Area'}.merge(predefined_types)
    
    @tracker_options = { l(:label_tracker_all) => 0 }
    @project.trackers.order(:name).map{ |t| @tracker_options[t.name] = t.id.to_s }
    
    @range_type_options = { l(:label_day_plural) => 'days', l(:label_month_plural) => 'months', l(:label_year_plural) => 'years' }
  end

  def create
    @chart = Chart.new(chart_params)
    @project = Project.find(@chart.project_id)

    if @chart.save
      redirect_to @chart
    else
      params[:name] ||= @chart.name
      params[:tracker_id] ||= @chart.tracker_id.to_s
      params[:chart_type] ||= @chart.chart_type
      params[:group_by_field] ||= @chart.group_by_field
      params[:is_public] ||= @chart.is_public.to_s
      params[:range_integer] ||= @chart.range_integer.to_s
      params[:range_type] ||= @chart.range_type
      params[:time] ||= @chart.time
      params[:issue_status] ||= @chart.issue_status

      set_options

      respond_to do |format|
        format.html { redirect_to action: 'new', project_id: @project.identifier }
        format.api  { render_validation_errors(@chart) }
      end
    end
  end

  def edit
    @chart = Chart.find(params[:id])
    @project = Project.find(@chart.project_id)
    params[:name] = @chart.name
    params[:tracker_id] = @chart.tracker_id.to_s
    params[:chart_type] = @chart.chart_type
    params[:group_by_field] = @chart.group_by_field
    params[:is_public] = @chart.is_public.to_s
    params[:range_integer] = @chart.range_integer.to_s
    params[:range_type] = @chart.range_type
    params[:time] = @chart.time
    params[:issue_status] = @chart.issue_status

    @chart_type_options = { l(:label_line_chart) => 'Line',
      l(:label_pie_chart) => 'Pie',
      l(:label_column_chart) => 'Column',
      l(:label_bar_chart) => 'Bar',
      l(:label_area_chart) => 'Area'}.merge(predefined_types)
    
    @tracker_options = { l(:label_tracker_all) => 0 }
    @project.trackers.order(:name).map{ |t| @tracker_options[t.name] = t.id.to_s }
    
    @range_type_options = { l(:label_day_plural) => 'days', l(:label_month_plural) => 'months', l(:label_year_plural) => 'years' }
    
    if !predefined_types.values.include?(params[:chart_type])
      @issue_status_options = { l(:label_open_issues_plural) => 'o', l(:label_closed_issues_plural) => 'c', l(:label_total) => '*' }
      @time_options = { l(:field_estimated_hours) => 'estimated_hours', l(:label_spent_time) => 'spent_hours' }
    end

    unless params[:chart_type].to_s.empty? || predefined_types.values.include?(params[:chart_type])
      options = standard_fields
      if params[:time] == 'spent_hours'
        options.delete(l(:field_created_on))
      end
      @group_by_field_options = { l(:field_tracker) => 'tracker' }.merge(options) if (params[:tracker_id] == '0' || !params[:time].to_s.empty?)
      @group_by_field_options = group_by_field_options(params[:tracker_id]) unless (params[:tracker_id] == '' || params[:tracker_id] == '0' || !params[:time].to_s.empty?)
    end

    if !(User.current.allowed_to?(:edit_charts, @project) || User.current.allowed_to?(:edit_public_charts, @project))
      render_404
    end
  end

  def update
    @chart = Chart.find(params[:id])
    @project = Project.find(@chart.project_id)
    if @chart.update_attributes(chart_params)
      redirect_to action: 'show', id: @chart.id
      flash[:notice] = l(:notice_successful_update)
    else
      params[:name] ||= @chart.name
      params[:tracker_id] ||= @chart.tracker_id.to_s
      params[:chart_type] ||= @chart.chart_type
      params[:group_by_field] ||= @chart.group_by_field
      params[:is_public] ||= @chart.is_public.to_s
      params[:range_integer] ||= @chart.range_integer.to_s
      params[:range_type] ||= @chart.range_type
      params[:time] ||= @chart.time
      params[:issue_status] ||= @chart.issue_status

      set_options

      respond_to do |format|
        format.html { redirect_to action: 'edit', id: @chart.id }
        format.api  { render_validation_errors(@chart) }
      end
    end
  end

  def destroy
    @chart = Chart.find(params[:id])
    @project = Project.find(@chart.project_id)
    if !(User.current.allowed_to?(:edit_charts, @project) || User.current.allowed_to?(:edit_public_charts, @project))
      render_404
    else
      @chart.destroy
      redirect_to action: 'index', project_id: @project.identifier
      flash[:notice] = l(:notice_successful_delete)
    end
  end

  private

    def chart_params
      params.require(:chart).permit(:project_id, :name, :tracker_id, :chart_type, :group_by_field, :user_id, :is_public, :range_integer, :range_type, :time, :issue_status)
    end

end
