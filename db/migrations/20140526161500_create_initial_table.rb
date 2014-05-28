Sequel.migration do
  change do
    create_table(:metrics) do
      primary_key :id
      foreign_key :pod_id, :pods, :null => false, :key => [:id]

      Integer :github_stars, :null => true
      Integer :github_forks, :null => true
      Integer :github_watchers, :null => true
      Integer :github_contributors, :null => true
      Integer :github_pull_requests, :null => true
      DateTime :github_first_commit, :null => true
      DateTime :github_last_commit, :null => true

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
