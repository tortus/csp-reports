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
    DataMapper.auto_migrate!
    puts "Success!"
  end

end
