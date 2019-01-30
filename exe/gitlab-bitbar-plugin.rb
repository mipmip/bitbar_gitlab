#!/usr/bin/env ruby

require "bundler/setup"
require "bitbar_gitlab"

require 'yaml'
require 'gitlab'

def run
  puts "GitLab"
  puts "---"

  puts "Refresh | refresh=true"

  if CONFIG['PROJECT_FOCUS'] and CONFIG['PROJECT_FOCUS']!=0
    puts "---"

    focus_project = $gitlab.project(CONFIG['PROJECT_FOCUS'])

    puts "PROJECT: #{focus_project.to_hash['name']} | href=#{focus_project.to_hash['web_url']}"
    puts "Issues"
    project_menu focus_project, 1, true
    puts "---"
  end

  if CONFIG['PIPELINE_FOCUS'] and CONFIG['PIPELINE_FOCUS']!=0
    puts "---"

    focus_pipeline = $gitlab.project(CONFIG['PIPELINE_FOCUS'])

    puts "PIPELINE: #{focus_project.to_hash['name']} | href=#{focus_project.to_hash['web_url']}"
    pipeline_focus_menu focus_pipeline, 0

    puts "---"
  end


  if toggle_on? 'show_starred_projects'
    puts "Starred Projects"

    $gitlab.projects(per_page: 9999, starred: 1).collect do |pr|
      puts "#{indent 1}" + pr.to_hash['id'].to_s + ' ' + pr.to_hash['name']
      project_menu pr, 2
    end
  end

  if toggle_on? 'show_all_projects'
    puts "All Projects"

    $gitlab.projects(per_page: 9999).collect do |pr|
      puts "#{indent 1}" + pr.to_hash['id'].to_s + ' ' + pr.to_hash['name']
      project_menu pr, 2
    end
  end

  if toggle_on? 'show_starred_pipelines'
    puts "Starred Pipelines"
    $gitlab.projects(per_page: 9999, starred: 1).collect do |pr|
      puts "#{indent 1}" + pr.to_hash['id'].to_s + ' ' + pr.to_hash['name']
      pipeline_menu pr, 2
    end
  end
  if toggle_on? 'show_all_pipelines'
    puts "All Pipelines"
    $gitlab.projects(per_page: 9999).collect do |pr|
      puts "#{indent 1}" + pr.to_hash['id'].to_s + ' ' + pr.to_hash['name']
      pipeline_menu pr, 2
    end
  end

  puts "---"
  puts "Toggles"
  toggle_line 1, 'show_starred_projects', "Show starred projects", "Hide starred projects"
  toggle_line 1, 'show_all_projects', "Show all projects", "Hide all projects"
  puts "#{indent 1}Clear issue focus | bash=~/.BitBar/gitlab-bitbar-lib/shellwrap.sh param1=set param2=pipeline_focus param3=0 terminal=false refresh=true"
  puts "#{indent 1} ---"
  toggle_line 1, 'show_starred_pipelines', "Show starred pipelines", "Hide starred pipelines"
  toggle_line 1, 'show_all_pipelines', "Show all pipelines", "Hide all pipelines"
  puts "#{indent 1}Clear pipeline focus | bash=~/.BitBar/gitlab-bitbar-lib/shellwrap.sh param1=set param2=pipeline_focus param3=0 terminal=false refresh=true"
end

def install_test_gitlab_connection
  puts "Testing GitLab connection"

  $gitlab = Gitlab.client(endpoint: CONFIG['ENDPOINT'], private_token: CONFIG['TOKEN'])

  begin
    user = $gitlab.user
    puts "User connected to this token: " + user.to_hash['name'] + "\n"
    puts


    puts "The configuration seems correct. you can now try using BitBar"

  rescue
    puts "ERROR Could not connect to the Gitlab API"
    puts
    puts "You may want to delete the configuration file and try to reconfigure"
    puts
    print "Shall I delete it for you? "
    delete_conf = STDIN.gets.chomp.upcase
    if delete_conf == "YES" or delete_conf == "Y"
      File.delete CONFIG_FILE
      puts "Deleted conf file. You can run this install again"
    end
    puts
  end

end

def install_bitbar_symlinks
  puts "Installing Symlinks to BitBar plugin folder"
  if File.exists? File.expand_path(CONFIG['PLUGIN_FOLDER'])+'/gitlab-bitbar-plugin.rb'
    File.delete File.expand_path(CONFIG['PLUGIN_FOLDER'])+'/gitlab-bitbar-plugin.rb'
  end
  File.symlink(File.expand_path(__FILE__), File.expand_path(CONFIG['PLUGIN_FOLDER'])+'/gitlab-bitbar-plugin.rb')
end

CONFIG_FILE =File.expand_path('~/.bitbar_gitlab_cnf.yml')

if ARGV[0]=='install'
  puts "Installing BitBar Gitlab Plugin by Pim Snel"

  if File.exists? CONFIG_FILE
    puts "you seem to have a configations file."
    puts
  else

    newconf = {}
    puts "Creating a minimal configuration file..."
    puts
    puts "Enter the URL to your GitLab Environment"
    puts "E.g. https://gitlab.yourcompany.net (no ending slash)"
    puts
    print "Api URL: "
    api_address = STDIN.gets.chomp
    newconf['ENDPOINT'] = api_address + "/api/v4"

    puts
    puts "Enter a GitLab Access token for your GitLab Environment"
    puts "Create them at #{api_address}/profile/personal_access_tokens"
    puts
    print "Access Token: "
    newconf['TOKEN'] = STDIN.gets.chomp

    ## Check BitBar plugin folder
    plugin_folder = `defaults read com.matryer.BitBar | grep pluginsDirectory | cut -d '"' -f2`.strip
    if File.exists? File.expand_path(plugin_folder)
      puts "I found this BitBar plugin folder: " + plugin_folder + "\n"
      newconf['PLUGIN_FOLDER'] = plugin_folder
    else
      puts "Could not find the BitBar plugin folder."
      print "Please enter the plugin path: "
      newconf['PLUGIN_FOLDER'] = STDIN.gets.chomp
    end

    newconf['EXE_UTIL_DIR'] = File.dirname(File.expand_path(__FILE__))

    puts
    puts "writing configuration file..."
    puts
    File.open(CONFIG_FILE, 'w') { |file| file.write(newconf.to_yaml) }

  end

  CONFIG = YAML.load_file(CONFIG_FILE)
  install_test_gitlab_connection
  install_bitbar_symlinks

else
  if File.exists? CONFIG_FILE

    CONFIG = YAML.load_file(CONFIG_FILE)

    if ARGV[0]=='set'
      if ARGV[1] == 'project_focus' && ARGV[2]
        CONFIG['PROJECT_FOCUS']= ARGV[2].to_i
        File.open(CONFIG_FILE, 'w') { |file| file.write(CONFIG.to_yaml) }
      elsif ARGV[1].include?('TOGGLE_') && ARGV[2]
        CONFIG[ARGV[1]]= ARGV[2].to_i
        File.open(CONFIG_FILE, 'w') { |file| file.write(CONFIG.to_yaml) }
      else
        CONFIG[ARGV[1].upcase]= ARGV[2].to_i
        File.open(CONFIG_FILE, 'w') { |file| file.write(CONFIG.to_yaml) }
      end

    else
      $gitlab = Gitlab.client(endpoint: CONFIG['ENDPOINT'], private_token: CONFIG['TOKEN'])
      run
    end

  else
    puts "WARNING, could not execute BITBAR_GITLAB"
    puts
    puts "make sure '~/.bitbar_gitlab_cnf.yml' exists."
    puts "You might want to run 'gitlab-bitbar-plugin.rb install'"
  end
end
