Sequel.migration do
  change do
    create_table(:github_pod_metrics) do
      primary_key :id
      foreign_key :pod_id, :pods, :null => false, :key => [:id]

      Integer :subscribers, :null => true
      Integer :stargazers, :null => true
      Integer :forks, :null => true
      Integer :contributors, :null => true
      Integer :open_issues, :null => true
      Integer :open_pull_requests, :null => true

      DateTime :first_commit, :null => true
      DateTime :last_commit, :null => true

      Integer :not_found, :default => 0

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
