require 'rdoc/task'

RDoc::Task.new do |rdoc|
  rdoc.rdoc_dir = 'doc'
  rdoc.main = 'README.md'
  rdoc.rdoc_files.include('README.md', 'app/**/*.rb')
end

namespace :db do
  desc 'Run migrations: WARNING: destructive'
  task :migrate do
    require_relative 'boot'
    puts "Migrating database..."

    unless CSPReports.db.table_exists?(:reports)
      CSPReports.db.create_table(:reports) do
        primary_key :id, type: :bigint
        column :sha256, :text, null: false, index: true
        column :body, :text, null: false
        column :count, :integer, default: 1, null: false
        column :domain, :text
        column :document_uri, :text
        column :referrer, :text
        column :violated_directive, :text
        column :original_policy, :text
        column :blocked_uri, :text
        column :first_occurrence, :timestamp
        column :last_occurrence, :timestamp
      end
      CSPReports.db.run('CREATE SEQUENCE reports_id_seq START 1;')
      CSPReports.db.run("ALTER TABLE reports ALTER COLUMN id SET DEFAULT nextval('reports_id_seq'::regclass);")
    end
    CSPReports.db.run("CREATE OR REPLACE VIEW domains (domain, count) AS (SELECT domain, SUM(count) AS count FROM reports GROUP BY domain)")
  end

  desc 'Drop database'
  task :drop do
    require_relative 'boot'
    puts "Dropping all tables..."
    CSPReports.db.drop_table?(:reports)
    CSPReports.db.run('DROP SEQUENCE reports_id_seq;')
    CSPReports.db.run('DROP VIEW domains;')
  end
end
