class RenameUploadedFileToSubscriptionPlanExport < ActiveRecord::Migration
  def change
    rename_table :uploaded_files, :subscription_plan_exports
  end
end
