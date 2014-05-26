Sequel.migration do
  change do
    create_table(:metrics) do
      primary_key :id

      # Just as an example.
      #
      # Integer :github_stars, :null => true
      # Integer :github_forks, :null => true

      DateTime :created_at
      DateTime :updated_at
    end
  end
end