class AddPublicToCharts < ActiveRecord::Migration
  def change
    add_column :charts, :public, :boolean, :default => false
  end
end