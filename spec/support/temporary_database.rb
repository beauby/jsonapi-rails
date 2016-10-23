def with_temporary_database(db)
  setup_database(&db)
  reset_column_information
  yield
  delete_database
end

def setup_database(&block)
  # don't output all the migration activity
  ActiveRecord::Migration.verbose = false

  # switch the active database connection to an SQLite, in-memory database
  ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')

  # execute the migration, creating a table (dirty_items) and columns (body, email, name)
  ActiveRecord::Schema.define(version: 1) do
    instance_exec(&block)
  end
end

def reset_column_information
  all_tables.each do |table_name|
    class_name = table_name.classify
    ar_class = class_name.safe_constantize
    if ar_class
      ar_class.reset_column_information
      # unset it, so we can also clear active_record relationships
      # and other class-level stuff
      Object.send(:remove_const, class_name.to_sym)
    end
  end
end

def delete_database
  all_tables.each do |table|
    ActiveRecord::Base.connection.execute("DELETE FROM #{table} WHERE 1 = 1")
  end
end

def all_tables
  ActiveRecord::Base.
    connection.execute(
      %Q{
        SELECT name
        FROM sqlite_master
        WHERE type='table';
      }).map { |r| r[0] }
end
