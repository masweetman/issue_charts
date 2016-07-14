module ChartsHelper

  def render_chart(chart)
  	
    if chart.group_by_field?
      scope = Issue.where('project_id = ? AND tracker_id = ?', chart.project_id, chart.tracker_id)
  	  group_by = chart.group_by_field
  	elsif chart.group_by_custom_field?
      scope = CustomValue.where("customized_type = ? AND custom_field_id = ?", 'Issue', chart.group_by_custom_field).joins("INNER JOIN issues ON (custom_values.customized_id = issues.id)").where("project_id = ? AND tracker_id = ?", chart.project_id, chart.tracker_id)
      group_by = 'value'
    else
      return nil
    end

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
