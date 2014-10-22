require 'resolv'
include_recipe 'deploy'

Chef::Log.info "Mysql deployment"
node[:deploy].each do |application, deploy|
#next if deploy[:database].nil? || deploy[:database].empty?

  mysql_command = "/usr/bin/mysql -u root #{node[:mysql][:server_root_password].blank? ? '' : "-p#{node[:mysql][:server_root_password]}"}"
  execute "create mysql database" do
     Chef::Log.info "Creating mysql database"
    command "#{mysql_command} -e 'CREATE DATABASE `#{deploy[:database][:db]}`' "
    action :run

    not_if do
      system("#{mysql_command} -e 'SHOW DATABASES' | egrep -e '^#{deploy[:database][:db]}$'")
    end
  end

  # this is legacy and you should not rely on it
  ruby_block "get hosts list" do
    block do
      if Chef::VERSION > "0.9"
        template = run_context.resource_collection.find(:template => "/tmp/grants.sql")
      else
        # this is a bug, and should just be 'resources'
        template = @collection.resources(:template => "/tmp/grants.sql")
      end
      status, stdout, stderr = Chef::Mixin::Command.output_of_command("echo 'select host from db where db=\"#{deploy[:database][:database]}\" and user =\"root\"' | #{mysql_command} --skip-column-names mysql", {})
      template.variables[:hosts] = stdout.split("\n").delete_if{|host| host == '127.0.0.1' || host == 'localhost'}
    end
  end

  template "/tmp/grants.sql" do
    source 'grants.sql.erb'
    owner 'root'
    group 'root'
    mode '0600'
    variables :username => deploy[:database][:username],:hosts => [], :settings => deploy[:database], :stack_clients => node[:mysql][:clients].select{|private_ip| Resolv.getaddress(private_ip) }
    cookbook "mysql"
    action :create
  end

  execute 'create grants' do
     Chef::Log.info "Creating grants"
    command "#{mysql_command} < /tmp/grants.sql"
  end
end
