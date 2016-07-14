module ChartsHelper

  def chart_type_options
    return ['Line', 'Pie', 'Column', 'Bar', 'Area']
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
    if chart.tracker_id == 0
      scope = Issue.where('project_id = ?', chart.project_id)
      group_by = chart.group_by_field
    elsif standard_fields.values.include? chart.group_by_field
      scope = Issue.where('project_id = ? AND tracker_id = ?', chart.project_id, chart.tracker_id)
  	  group_by = chart.group_by_field
  	elsif group_by_field_options(chart.tracker_id).values.include? chart.group_by_field
      scope = CustomValue.where("customized_type = ? AND custom_field_id = ?", 'Issue', chart.group_by_field).joins("INNER JOIN issues ON (custom_values.customized_id = issues.id)").where("project_id = ? AND tracker_id = ?", chart.project_id, chart.tracker_id)
      group_by = 'value'
    else
      return nil
    end

    if group_by == 'created_on'
      case
        when chart.chart_type.downcase == 'line'
          line_chart scope.group_by_day(group_by).count
        when chart.chart_type.downcase == 'pie'
          pie_chart scope.group_by_day(group_by).count
        when chart.chart_type.downcase == 'column'
          column_chart scope.group_by_day(group_by).count
        when chart.chart_type.downcase == 'bar'
          bar_chart scope.group_by_day(group_by).count
        when chart.chart_type.downcase == 'area'
          area_chart scope.group_by_day(group_by).count
        else
          nil
      end
    else
    	case
        when chart.chart_type.downcase == 'line'
          line_chart scope.group(group_by).count
        when chart.chart_type.downcase == 'pie'
        	pie_chart scope.group(group_by).count
        when chart.chart_type.downcase == 'column'
        	column_chart scope.group(group_by).count
        when chart.chart_type.downcase == 'bar'
          bar_chart scope.group(group_by).count
        when chart.chart_type.downcase == 'area'
        	area_chart scope.group(group_by).count
        else
        	nil
      end
    end
  end

end
