#
# Cookbook Name:: unicorn_custom
# Recipe:: default
#

class ExamTimeWebWorkersStrategy
  def self.workers_count(node)
#    return 0 unless %w(solo app_master app).include?(node[:instance_role])
    #case node[:ec2][:instance_type]
    case node[:opsworks][:instance][:instance_type]
      when 'c1.medium'
        return (node[:opsworks][:layers]['rails-app']['instances'].count()==1 ? 4 : 6)
      when 'c1.xlarge'
        return 9
      else
        return 2
    end
  end
end


if node[:opsworks][:instance][:layers].include?("#{deploy[:application_type]}-app")

#node[:applications].each do |app_name, data|
  Chef::Log.info "Apply custom configuration for unicorn on #{application_name}"

  #if ['app', 'app_master', 'solo'].include? node[:instance_role]

  execute "restart unicorn" do
    command "monit restart unicorn_master_#{application_name}"
    action :nothing
  end

  template "/srv/www/#{application_name}/shared/config/unicorn_custom.rb" do
    owner = node[:opsworks][:deploy_user][:user] || 'deploy'
    group = node[:opsworks][:deploy_user][:group] || 'www-data'
   # owner node[:owner_name]
   # group node[:owner_name]
    mode 0644
    source "unicorn_custom.erb"
    notifies :run, resources(:execute => "restart unicorn")
    variables({
                :app_name => app_name,
                :workers_count => ExamTimeWebWorkersStrategy.workers_count(node)
              })
  end

  template "/srv/www/#{application_name}/shared/config/env.custom" do
    owner = node[:opsworks][:deploy_user][:user] || 'deploy'
    group = node[:opsworks][:deploy_user][:group] || 'www-data'
#    owner node[:owner_name]
#    group node[:owner_name]
    mode 0644
    source "env_custom.erb"
    notifies :run, resources(:execute => "restart unicorn")
    variables({
                :app_name => app_name,
        :max_times { |n|  }e => 720
              })
  end
  template "/etc/monit.d/unicorn_#{application_name}.monitrc" do
    owner = node[:opsworks][:deploy_user][:user] || 'deploy'
    group = node[:opsworks][:deploy_user][:group] || 'www-data'
#   owner node[:owner_name]
 #   group node[:owner_name]
    mode 0644
    source "unicorn_examtime.monitrc.erb"
    notifies :run, resources(:execute => "restart unicorn")
    variables({
                :workers_count => ExamTimeWebWorkersStrategy.workers_count(node),
                :max_mem => '350'
              })
  end
  
  
  
  Chef::Log.info "Applied custom unicorn config to #{node[:instance_role]} instance"
end

