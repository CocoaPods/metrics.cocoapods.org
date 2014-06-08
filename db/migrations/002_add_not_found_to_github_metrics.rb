Sequel.migration do
  change do
    alter_table(:github_metrics) do
      add_column :not_found, Integer, :default => 0
    end
  end
end
