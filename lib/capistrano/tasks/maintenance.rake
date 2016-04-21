namespace :maintenance do
  desc "Turn on maintenance mode"
  task :enable do
    on roles(:web) do
      require 'erb'

      reason = ENV['REASON']
      deadline = ENV['UNTIL']

      default_template = File.join(File.expand_path('../../templates', __FILE__), 'maintenance.html.erb')
      template = fetch(:maintenance_template_path, default_template)
      rails_path = fetch(:maintenance_rails_path, "/public/system/")
      result = ERB.new(File.read(template)).result(binding)

      rendered_path = "#{shared_path}#{rails_path}"
      rendered_name = "#{fetch(:maintenance_basename, 'maintenance')}.html"

      if test "[ ! -d #{rendered_path} ]"
        info 'Creating missing directories.'
        execute :mkdir, '-pv', rendered_path
      end

      upload!(StringIO.new(result), rendered_path + rendered_name)
      execute "chmod 644 #{rendered_path + rendered_name}"
    end
  end

  desc "Turn off maintenance mode"
  task :disable do
    on roles(:web) do
      rails_path = fetch(:maintenance_rails_path, "/public/system/")
      execute "rm -f #{shared_path}#{rails_path}#{fetch(:maintenance_basename, 'maintenance')}.html"
    end
  end
end
