class RenameColumns < ActiveRecord::Migration
  def change
    rename_column :charts, :public, :is_public
  end
end