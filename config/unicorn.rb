require './modules/cache'
require './modules/file_storage'

# set path to app that will be used to configure unicorn, 
# note the trailing slash in this example
@dir = "./"

worker_processes 2
working_directory @dir

timeout 30

after_fork do |server, worker|
  EasyCache::Cache.connect!
  EasyCache::RemoteFile.connect!
end
