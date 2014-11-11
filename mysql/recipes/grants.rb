include_recipe 'deploy'



node[:deploy].each do |application, deploy|

  mysql_command = "/usr/bin/mysql -uroot -p#{node[:mysql][:server_root_password]}"

  execute "grant privileges to deploy user" do
    command "#{mysql_command} -e 'GRANT ALL PRIVILEGES on '#{deploy[:database][:database]}'@'%' to  '#{deploy[:database][:username]}' identified by '#{deploy[:database][:password]}'' "
    action :run
  
  end
end
