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
    Tracker.find(tracker_id).custom_fields.order(:name).map{ |cf| options[cf.name] = cf.id.to_s }
    return options
  end

  def render_chart(chart)
    
    date_range = nil
    date_range = eval("Date.today - chart.range_integer." + chart.range_type) unless chart.range_integer.nil? || chart.range_type.nil?
    if chart.predefined?
      if chart.tracker_id == 0
        scope = Issue.where('project_id = ? AND created_on > ?', chart.project_id, date_range)
      else
        scope = Issue.where('project_id = ? AND tracker_id = ? AND created_on > ?', chart.project_id, chart.tracker_id, date_range)
      end
    else
      group = chart.group_by_field
      if chart.tracker_id == 0
        scope = Issue.where('project_id = ? AND created_on > ?', chart.project_id, date_range)
      elsif standard_fields.values.include? chart.group_by_field
        scope = Issue.where('project_id = ? AND tracker_id = ? AND created_on > ?', chart.project_id, chart.tracker_id, date_range)
      elsif group_by_field_options(chart.tracker_id).values.include? chart.group_by_field
        scope = CustomValue.where("customized_type = ? AND custom_field_id = ?", 'Issue', chart.group_by_field).joins("INNER JOIN issues ON (custom_values.customized_id = issues.id)").where("project_id = ? AND tracker_id = ? AND created_on > ?", chart.project_id, chart.tracker_id, date_range)
        group = 'value'
      end
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
    end
    
    if chart.chart_type == 'Created vs Closed Issues'
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

  end

end
