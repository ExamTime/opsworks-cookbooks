include_recipe "nginx::service"

deploy = node[:deploy]
app_name = params[:app]


config_path="/etc/nginx/conf.d"
#if %( app_master app solo ).include?(node[:instance_role])
app_name = node[:deploy]['demo'][:application]

directory "#{config_path}/#{app_name}" do
  mode 0755
  owner node[:nginx][:user]
  action :create
end
 
template "#{config_path}/#{app_name}/custom.conf" do
#  owner deploy[:user]
#  group deploy[:group]
  mode 0644
  source "custom.erb"
#  if node[:environment][:name]!='production'
  if node[:deploy][:application]!='production'
    variables(
        :allowed_ips => 'satisfy any;
allow 54.192.0.0/16; 
allow 54.230.0.0/16; 
allow 54.239.128.0/18; 
allow 54.239.192.0/19; 
allow 54.240.128.0/18; 
allow 204.246.164.0/22; 
allow 204.246.168.0/22; 
allow 204.246.174.0/23; 
allow 204.246.176.0/20; 
allow 205.251.192.0/19; 
allow 205.251.249.0/24; 
allow 205.251.250.0/23; 
allow 205.251.252.0/23; 
allow 205.251.254.0/24; 
allow 216.137.32.0/19; 
deny all;',

        :auth_basic => 'auth_basic "ExamTime integration - Company Confidential - this site is restricted to ExamTime staff only";',
	:auth_basic_user_file => "auth_basic_user_file /data/nginx/servers/examtime/examtime.users;"
      )
    end
  end

template "#{config_path}/#{app_name}/custom.ssl.conf" do
#  owner deploy[:user]
#  group deploy[:group]
  mode 0644
  source "custom.erb"
#    if node[:environment][:name]!='production'
  if node[:deploy][:application]!='production'
    variables(
      :allowed_ips => 'satisfy any; 
allow 54.192.0.0/16; 
allow 54.230.0.0/16; 
allow 54.239.128.0/18; 
allow 54.239.192.0/19; 
allow 54.240.128.0/18; 
allow 204.246.164.0/22; 
allow 204.246.168.0/22; 
allow 204.246.174.0/23; 
allow 204.246.176.0/20; 
allow 205.251.192.0/19; 
allow 205.251.249.0/24; 
allow 205.251.250.0/23; 
allow 205.251.252.0/23; 
allow 205.251.254.0/24; 
allow 216.137.32.0/19; 
deny all;',
      :auth_basic => 'auth_basic "ExamTime integration - Company Confidential - this site is restricted to ExamTime staff only";',
      :auth_basic_user_file => "auth_basic_user_file /data/nginx/conf.d/examtime.users;"
      )
  end
end


template "#{config_path}/examtime.conf" do
#  owner deploy[:user]
#  group deploy[:group]
  owner node[:nginx][:user]
  mode 0644
  source "app.erb"
  variables(
    :deploy => deploy,
    :application => app_name,
    :custom_path => "#{config_path}/#{app_name}"
     )
end


# template "#{config_path}/examtimessl.conf" do
# #  owner deploy[:user]
# #  group deploy[:group]
#   mode 0644
#   source ""
#   backup false
#   action :create
# end



cookbook_file "#{config_path}/proxy.conf" do
#  owner deploy[:user]
#  group deploy[:group]
  mode 0644
  source 'proxy.conf'
  backup false
  action :create
end


cookbook_file "#{config_path}/http-custom.conf" do
#  owner deploy[:user]
#  group deploy[:group]
  mode 0644
  source "http-custom.conf"
  backup false
  action :create
end


src_filename1 = "GeoIP.dat.gz"
src_filename2 = "GeoLiteCity.dat.gz"
src_filepath = "/etc/nginx"


cookbook_file "#{src_filepath}/#{src_filename1}" do
#  owner deploy[:user]
#  group deploy[:group]
  mode 0644
  source "#{src_filename1}"
end

cookbook_file "#{src_filepath}/#{src_filename2}" do
#  owner deploy[:user]
#  group deploy[:group]
  mode 0644
  source "#{src_filename2}"
end

bash 'extract_module' do
  cwd ::File.dirname(src_filepath)
  code <<-EOH
      gunzip -f #{src_filepath}/#{src_filename1}
      gunzip -f #{src_filepath}/#{src_filename2}

  EOH
#    not_if { ::File.exists?(#{src_filename1}) }
     
end
# Restart nginx

  # execute "Restart nginx" do
  #   command %Q{
  #       /etc/init.d/nginx restart
  #     }
  # end
service "nginx" do
  action [ :restart ]
end

  
Chef::Log.info "Nginx configuration deployed"

