class AddIssueStatusToCharts < ActiveRecord::Migration
  def change
    add_column :charts, :issue_status, :string, :default => 'o'
  end
end