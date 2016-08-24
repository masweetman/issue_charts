module ChartsHelper

  def chart_type_options
    return { l(:label_line_chart) => 'Line',
      l(:label_pie_chart) => 'Pie',
      l(:label_column_chart) => 'Column',
      l(:label_bar_chart) => 'Bar',
      l(:label_area_chart) => 'Area'}.merge(predefined_types)
  end

  def predefined_types
    return { l(:label_created_vs_closed_issues) => 'Created vs Closed Issues' }
  end

  def standard_fields
    return { l(:field_category) => 'category', l(:field_status) => 'status', l(:field_assigned_to) => 'assigned_to', l(:field_author) => 'author', l(:field_created_on) => 'created_on' }
  end

  def tracker_options
    options = { l(:label_tracker_all) => 0 }
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
  
  def all_project_children(project)
    project.children.map do |child|
      [child.id] + all_project_children(child)
    end.flatten.uniq
  end

  def issue_scope(chart)
    start_date = chart_start_date(chart)
    if chart.tracker_id == 0
      scope = Issue.where('issues.project_id IN (?) AND issues.created_on > ?', chart.projects, start_date)
    else
      scope = Issue.where('issues.project_id IN (?) AND issues.tracker_id = ? AND issues.created_on > ?', chart.projects, chart.tracker_id, start_date)
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

  def chart_issues_path(chart, object_id, status)
    begin
      if chart.group_by_field == 'status'
        status_op = '='
      else
        status_op = status
      end
      if chart.tracker_id > 0
        project_issues_path(Project.find(chart.project_id), :set_filter => 1,
          :f=>[:status_id, :tracker_id, :created_on, chart.group_by_field.to_s + '_id'],
          :op=>{:status_id => status_op, :tracker_id => '=', :created_on => '>=', chart.group_by_field.to_s + '_id' => '='},
          :v=>{:tracker_id => [chart.tracker_id.to_s], :created_on => [chart_start_date(chart).to_s], chart.group_by_field.to_s + '_id' => [object_id.to_s]},
          :c=>[:tracker, :status, :priority, :subject, :assigned_to, :estimated_hours, :spent_hours]
          )
      elsif chart.tracker_id == 0
        project_issues_path(Project.find(chart.project_id), :set_filter => 1,
          :f=>[:status_id, :created_on, chart.group_by_field.to_s + '_id'],
          :op=>{:status_id => status_op, :created_on => '>=', chart.group_by_field.to_s + '_id' => '='},
          :v=>{:created_on => [chart_start_date(chart).to_s], chart.group_by_field.to_s + '_id' => [object_id.to_s]},
          :c=>[:tracker, :status, :priority, :subject, :assigned_to, :estimated_hours, :spent_hours]
          )
      end
    rescue Exception => e
      flash[:error] = "Error loading links for chart '" + chart.name + "'. " + e.message
    end
  end

  def chart_issues_count(chart, object_id, status)
    query = chart.group_by_field.to_s + '_id = ?'
    scope = issue_scope(chart).where(query, object_id)
    if status == 'o'
      count = scope.open.count
    elsif status == '*'
      count = scope.count
    elsif status == 'c'
      count = scope.count - scope.open.count
    end
    return count
  end

  def render_chart(chart)
    begin
      start_date = chart_start_date(chart)
      if ('0' + chart.group_by_field.to_s).to_i > 0
        scope = CustomValue.where("customized_type = ? AND custom_field_id = ?", 'Issue', chart.group_by_field).joins("INNER JOIN issues ON (custom_values.customized_id = issues.id)").where("project_id IN (?) AND tracker_id = ? AND created_on > ?", chart.projects, chart.tracker_id, start_date)
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
        
        if chart.time.to_s.empty?
          code = chart_code + ' scope.' + group_code + '(group).count'
        else
          code = chart_code + ' scope.' + group_code + '(group).' + 'sum(:estimated_hours)' if chart.time == 'estimated_hours'
          code = chart_code + ' scope.joins(:time_entries).' + group_code + '(group).' + 'sum(:hours)' if chart.time == 'spent_hours'
        end

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

        closed_series.each do |cl|
          unless created_series.include? cl[0]
            created_series[cl[0]] = created_series.each.select{ |i| i[0] < cl[0] }.max.to_a[1].to_i
          end
        end
        created_series.each do |cr|
          unless closed_series.include? cr[0]
            closed_series[cr[0]] = closed_series.each.select{ |i| i[0] < cr[0] }.max.to_a[1].to_i
          end
        end

        code = "area_chart [ { name: 'Created Issues', data: created_series }, { name: 'Closed Issues', data: closed_series } ], stacked: false, max: created_issues*1.1, colors: ['red', '#0a0']"
      end

      eval code
    rescue Exception => e
      flash[:error] = "Error loading chart '" + chart.name + "'. " + e.message
      return ''
    end
  end

end
