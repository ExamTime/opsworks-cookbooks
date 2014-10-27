include_recipe "nginx::service"

#if %( app_master app solo ).include?(node[:instance_role])

template "/etc/nginx/servers/examtime/custom.conf" do
  owner "deploy"
  group "deploy"
  mode 0644
  source "custom.erb"
#  if node[:environment][:name]!='production'
  if deploy[application][:environment]!='production'
    variables({
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
	:auth_basic_user_file => "auth_basic_user_file /data/nginx/servers/examtime/examtime.users;",
      })
    end
  end

template "/etc/nginx/servers/examtime/custom.ssl.conf" do
  owner "deploy"
  group "deploy"
  mode 0644
  source "custom.erb"
#    if node[:environment][:name]!='production'
  if deploy[application][:environment]!='production'
    variables({
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
      :auth_basic_user_file => "auth_basic_user_file /data/nginx/servers/examtime/examtime.users;",
      })
  end
end

remote_file "/etc/nginx/common/proxy.conf" do
  owner "deploy"
  group "deploy"
  mode 0644
  source "proxy.conf"
  backup false
  action :create
end


remote_file "/etc/nginx/http-custom.conf" do
  owner "deploy"
  group "deploy"
  mode 0644
  source "http-custom.conf"
  backup false
  action :create
end


src_filename1 = "GeoIP.dat.gz"
src_filename2 = "GeoLiteCity.dat.gz"
src_filepath = "/etc/nginx"


remote_file "#{src_filepath}/#{src_filename1}" do
  owner "deploy"
  group "deploy"
  mode 0644
  source "#{src_filename1}"
end

remote_file "#{src_filepath}/#{src_filename2}" do
  owner "deploy"
  group "deploy"
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


ey_cloud_report "nginx_config" do
  message "Nginx configuration deployed"
end

