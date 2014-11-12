include_recipe 'mysql'



node[:deploy].each do |application, deploy|
  puts deploy
  mysql_command = "/usr/bin/mysql -uroot -p#{node[:mysql][:server_root_password]}"
  db=deploy[:database][:database]
  user=deploy[:database][:username]
  pass=deploy[:database][:password]

  execute "grant privileges to deploy user" do
    command "#{mysql_command} -e 'GRANT ALL PRIVILEGES on #{db}.* to #{user}@`%` identified by `#{password}`   

#`#{deploy[:database][:database]}`.* to #{deploy[:database][:username]}@`%` identified by "#{deploy[:database][:password]}" ' "
    action :run
  
  end
end
