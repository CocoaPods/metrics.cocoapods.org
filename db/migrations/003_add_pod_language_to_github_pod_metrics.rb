Sequel.migration do
  change do
    alter_table(:github_pod_metrics) do
      add_column :language, String, :null => true
    end
  end
end
