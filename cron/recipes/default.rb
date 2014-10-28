#
# Cookbook Name:: cron
# Recipe:: default
#

if node[:opsworks][:instance][:layers].include?('db-master')
  cron "OPTIMIZE TABLE" do
  
    minute "0"
    hour "7"
    weekday "0"  
    user 'deploy'
    command '/usr/bin/mysql -e "OPTIMIZE TABLE examtime.sessions;" > /data/examtime/optimize_cronlog.txt 2>&1'
    Chef::Log.info "Cron optimize table added" 
  end
   
end 
