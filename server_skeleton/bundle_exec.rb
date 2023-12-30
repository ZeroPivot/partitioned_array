PID_LOC = "config/puma.pid"
pid = `cat #{PID_LOC}`
`kill #{pid}`
puts "MPM_DB_SERVER with PID: #{pid} was hopefully killed!"

exec("bundle exec rerun --dir . -- \"puma -C config/puma-mpa-db-local.rb\"")