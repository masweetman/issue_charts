class CreateCharts < ActiveRecord::Migration
  def change
    create_table :charts do |t|
      t.string :name
      t.integer :project_id
      t.integer :tracker_id
      t.string :chart_type
      t.string :group_by_field
      t.integer :group_by_custom_field
    end
  end
end
