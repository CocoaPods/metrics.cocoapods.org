# TODO Will this be a problem if we have multiple apps accessing the same migrations table?
# (What happens if one of the migrations in the table is not found in the project, because
# it came from another project?)
#
Sequel.migration do
  change do
    create_table(:metrics) do
      primary_key :id

      Integer  :github_stars, :null => true
      Integer  :github_forks, :null => true
      Integer  :github_watchers, :null => true
      Integer  :github_contributors, :null => true
      Integer  :github_pull_requests, :null => true
      DateTime :github_first_commit, :null => true
      DateTime :github_last_commit, :null => true

      DateTime :created_at
      DateTime :updated_at
    end
  end
end