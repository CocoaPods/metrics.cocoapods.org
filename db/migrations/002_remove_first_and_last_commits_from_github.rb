Sequel.migration do
  change do
    alter_table(:github_pod_metrics) do
      drop_column :first_commit
      drop_column :last_commit
    end
  end
end
