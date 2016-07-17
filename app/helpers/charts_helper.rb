module ChartsHelper

  def chart_type_options
    return ['Line', 'Pie', 'Column', 'Bar', 'Area'] + predefined_types
  end

  def predefined_types
    return ['Created vs Closed Issues']
  end

  def standard_fields
    return { 'Category' => 'category', 'Status' => 'status', 'Assigned to' => 'assigned_to', 'Author' => 'author', 'Created on' => 'created_on' }
  end

  def tracker_options
    options = { 'All trackers' => 0 }
    Tracker.order(:name).map{ |t| options[t.name] = t.id.to_s }
    return options
  end

  def group_by_field_options(tracker_id)
    options = standard_fields
    group_by_custom_field_options(tracker_id).map{ |cf| options[cf.name] = cf.id.to_s }
    return options
  end

  def group_by_custom_field_options(tracker_id)
    return Tracker.find(tracker_id).custom_fields.order(:name)
  end

  def chart_start_date(chart)
    eval("Date.today - chart.range_integer." + chart.range_type) unless chart.range_integer.nil? || chart.range_type.nil?
  end

  def issue_scope(chart)
    start_date = chart_start_date(chart)
    if chart.tracker_id == 0
      scope = Issue.where('project_id = ? AND created_on > ?', chart.project_id, start_date)
    else
      scope = Issue.where('project_id = ? AND tracker_id = ? AND created_on > ?', chart.project_id, chart.tracker_id, start_date)
    end
  end

  def render_link_objects(chart)
    objects = []
    if ('0' + chart.group_by_field.to_s).to_i > 0
      return nil
    else
      scope = issue_scope(chart)
      objects = scope.map{ |i| eval("i." + chart.group_by_field.to_s) }.uniq.compact.sort unless chart.group_by_field.to_s == 'created_on'
    end
    return objects
  end

  def chart_issues_path(chart, object)
    begin
      code = "project_issues_path(Project.find(" + chart.project_id.to_s + "), :set_filter => 1,"
      code += " :tracker_id => " + chart.tracker_id.to_s + "," if chart.tracker_id > 0
      code += " :status_id => '*'," unless chart.group_by_field.to_s == 'status'
      code += " :" + chart.group_by_field.to_s + "_id => " + object.class.name + ".find('" + object.id.to_s + "'))"
      eval code
    rescue Exception => e
      flash[:error] = "Error loading links for chart '" + chart.name + "'. " + e.message
    end
  end

  def render_chart(chart)
    begin
      start_date = chart_start_date(chart)
      if ('0' + chart.group_by_field.to_s).to_i > 0
        scope = CustomValue.where("customized_type = ? AND custom_field_id = ?", 'Issue', chart.group_by_field).joins("INNER JOIN issues ON (custom_values.customized_id = issues.id)").where("project_id = ? AND tracker_id = ? AND created_on > ?", chart.project_id, chart.tracker_id, start_date)
        group = 'value'
      else
        scope = issue_scope(chart)
        group = chart.group_by_field
      end

      if !chart.predefined?
        chart_code = ''
        if chart.chart_type == 'Line'
          chart_code = 'line_chart'
        elsif chart.chart_type == 'Pie'
          chart_code = 'pie_chart'
        elsif chart.chart_type == 'Column'
          chart_code = 'column_chart'
        elsif chart.chart_type == 'Bar'
          chart_code = 'bar_chart'
        elsif chart.chart_type == 'Area'
          chart_code = 'area_chart'
        end
        group_code = ''
        if group == 'created_on'
          group_code = 'group_by_day'
        else
          group_code = 'group'
        end
        code = chart_code + ' scope.' + group_code + '(group).count'

      elsif chart.chart_type == 'Created vs Closed Issues'
        created_issues = 0
        closed_issues = 0
        created_series = {}
        closed_series = {}
        scope.order(:created_on).each do |issue|
          created_issues += 1
          created_series[issue.created_on.to_date] = created_issues
        end
        scope.where('closed_on > ?', 0).order(:closed_on).each do |issue|
          closed_issues += 1
          closed_series[issue.closed_on.to_date] = closed_issues
        end
        code = "line_chart [ { name: 'Created Issues', data: created_series }, { name: 'Closed Issues', data: closed_series } ], max: created_issues"
      end

      eval code
    rescue Exception => e
      flash[:error] = "Error loading chart '" + chart.name + "'. " + e.message
      return ''
    end
  end

end
