$(function() {
  return $(document).on('change', '#chart_type_select', function(evt) {
    return $.ajax('update_edit_options', {
      type: 'GET',
      dataType: 'script',
      data: {
        'chart_type': $("#chart_type_select option:selected").val(),
        'name': $("#name_field").val(),
        'is_public': $("#public_checkbox").is(":checked"),
        'tracker_id': $("#tracker_select option:selected").val(),
        'time': $("#time_tracking_select option:selected").val(),
        'range_integer': $("#range_field").val(),
        'range_type': $("#date_range_type_select option:selected").val(),
        'group_by_field': $("#group_by_select option:selected").val(),
        'issue_status': $("#issue_status_select option:selected").val()
      },
      error: function(jqXHR, textStatus, errorThrown) {
        return console.log("AJAX Error: " + textStatus);
      },
      success: function(data, textStatus, jqXHR) {
        return console.log("Chart type selected");
      }
    });
  });
});

$(function() {
  return $(document).on('change', '#tracker_select', function(evt) {
    return $.ajax('update_edit_options', {
      type: 'GET',
      dataType: 'script',
      data: {
        'chart_type': $("#chart_type_select option:selected").val(),
        'name': $("#name_field").val(),
        'is_public': $("#public_checkbox").is(":checked"),
        'tracker_id': $("#tracker_select option:selected").val(),
        'time': $("#time_tracking_select option:selected").val(),
        'range_integer': $("#range_field").val(),
        'range_type': $("#date_range_type_select option:selected").val(),
        'group_by_field': $("#group_by_select option:selected").val(),
        'issue_status': $("#issue_status_select option:selected").val()
      },
      error: function(jqXHR, textStatus, errorThrown) {
        return console.log("AJAX Error: " + textStatus);
      },
      success: function(data, textStatus, jqXHR) {
        return console.log("Chart type selected");
      }
    });
  });
});

$(function() {
  return $(document).on('change', '#time_tracking_select', function(evt) {
    return $.ajax('update_edit_options', {
      type: 'GET',
      dataType: 'script',
      data: {
        'chart_type': $("#chart_type_select option:selected").val(),
        'name': $("#name_field").val(),
        'is_public': $("#public_checkbox").is(":checked"),
        'tracker_id': $("#tracker_select option:selected").val(),
        'time': $("#time_tracking_select option:selected").val(),
        'range_integer': $("#range_field").val(),
        'range_type': $("#date_range_type_select option:selected").val(),
        'group_by_field': $("#group_by_select option:selected").val(),
        'issue_status': $("#issue_status_select option:selected").val()
      },
      error: function(jqXHR, textStatus, errorThrown) {
        return console.log("AJAX Error: " + textStatus);
      },
      success: function(data, textStatus, jqXHR) {
        return console.log("Chart type selected");
      }
    });
  });
});