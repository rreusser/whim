require './modules/app'

@dir = "./"

worker_processes 4
working_directory @dir

timeout 30

after_fork do |server, worker|
  Whim::App.connect!
end
