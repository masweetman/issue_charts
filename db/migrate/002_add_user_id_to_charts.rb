class AddUserIdToCharts < ActiveRecord::Migration
  def change
    add_column :charts, :user_id, :integer
  end
end