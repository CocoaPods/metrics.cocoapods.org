Sequel.migration do
  change do
    create_table(:github_metrics) do
      primary_key :id
      foreign_key :pod_id, :pods, :null => false, :key => [:id]

      Integer :stars, :null => true
      Integer :forks, :null => true
      Integer :watchers, :null => true
      Integer :contributors, :null => true
      Integer :pull_requests, :null => true
      DateTime :first_commit, :null => true
      DateTime :last_commit, :null => true

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
