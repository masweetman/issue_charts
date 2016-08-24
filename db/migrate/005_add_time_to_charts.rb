class AddTimeToCharts < ActiveRecord::Migration
  def change
    add_column :charts, :time, :string, :default => ''
  end
end