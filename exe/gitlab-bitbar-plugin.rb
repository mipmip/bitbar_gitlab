#!/usr/bin/env ruby

require "bundler/setup"
require "bitbar_gitlab"

require 'yaml'
require 'gitlab'

#CONFIG_FILE = File.expand_path('~/.bitbar_gitlab_cnf.yml')
$conf = GitlabBitbarLibConfig.new


def run

  puts "GitLab"
  puts "---"

  puts "Refresh | refresh=true"

  if $conf.key_is_set :project_focus
    puts "---"

    focus_project = $gitlab.project($conf.get_key :project_focus)

    puts "PROJECT: #{focus_project.to_hash['name']} | href=#{focus_project.to_hash['web_url']}"
    puts "Issues"
    project_menu focus_project, 1, true
    puts "---"
  end

  if $conf.key_is_set :pipeline_focus
    puts "---"

    focus_pipeline = $gitlab.project($conf.get_key :pipeline_focus)

    puts "PIPELINE: #{focus_pipeline.to_hash['name']} | href=#{focus_pipeline.to_hash['web_url']}"
    pipeline_focus_menu focus_pipeline, 0

    puts "---"
  end

  if $conf.toggle_on? 'show_starred_projects'
    puts "Starred Projects"

    $gitlab.projects(per_page: 9999, starred: 1).collect do |pr|
      puts "#{indent 1}" + pr.to_hash['id'].to_s + ' ' + pr.to_hash['name']
      project_menu pr, 2
    end
  end

  if $conf.toggle_on? 'show_all_projects'
    puts "All Projects"

    $gitlab.projects(per_page: 9999).collect do |pr|
      puts "#{indent 1}" + pr.to_hash['id'].to_s + ' ' + pr.to_hash['name']
      project_menu pr, 2
    end
  end

  if $conf.toggle_on? 'show_starred_pipelines'
    puts "Starred Pipelines"
    $gitlab.projects(per_page: 9999, starred: 1).collect do |pr|
      puts "#{indent 1}" + pr.to_hash['id'].to_s + ' ' + pr.to_hash['name']
      pipeline_menu pr, 2
    end
  end
  if $conf.toggle_on? 'show_all_pipelines'
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
  puts "#{indent 1}Clear issue focus | bash=#{shellwrap} param1=set param2=pipeline_focus param3=0 terminal=false refresh=true"
  puts "#{indent 1}---"
  toggle_line 1, 'show_starred_pipelines', "Show starred pipelines", "Hide starred pipelines"
  toggle_line 1, 'show_all_pipelines', "Show all pipelines", "Hide all pipelines"
  puts "#{indent 1}Clear pipeline focus | bash=#{shellwrap} param1=set param2=pipeline_focus param3=0 terminal=false refresh=true"
end

def install_test_gitlab_connection
  puts "Testing GitLab connection"

  $gitlab = Gitlab.client(endpoint: $conf.get_key(:endpoint), private_token: $conf.get_key(:token))

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
      $conf.delete
      puts "Deleted conf file. You can run this install again"
    end
    puts
  end
end

def install_bitbar_symlinks
  puts "Installing Symlinks to BitBar plugin folder"
  unless $conf.get_key :plugin_folder
    plugin_folder = `defaults read com.matryer.BitBar | grep pluginsDirectory | cut -d '"' -f2`.strip
    $conf.set_key :plugin_folder, plugin_folder
  end

  if File.exists? File.expand_path($conf.get_key :plugin_folder)+'/gitlab-bitbar-plugin.rb'
    File.delete File.expand_path($conf.get_key :plugin_folder)+'/gitlab-bitbar-plugin.rb'
  end
  File.symlink(File.expand_path(__FILE__), File.expand_path($conf.get_key :plugin_folder)+'/gitlab-bitbar-plugin.rb')
end

if ARGV[0]=='install'

  puts "Installing BitBar Gitlab Plugin by Pim Snel"

  if $conf.exists?
    unless $conf.get_key :exe_util_dir
      $conf.set_key :exe_util_dir, File.dirname(File.expand_path(__FILE__))
    end
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
    $conf.save_init newconf
  end

  install_test_gitlab_connection
  install_bitbar_symlinks

elsif ARGV[0]=='set'

  unless $conf.get_key :exe_util_dir
    $conf.set_key :exe_util_dir, File.dirname(File.expand_path(__FILE__))
  end

  $conf.set_key ARGV[1].to_sym, ARGV[2].to_i
else

  if $conf.exists?

    unless $conf.get_key :exe_util_dir
      $conf.set_key :exe_util_dir, File.dirname(File.expand_path(__FILE__))
    end

    $gitlab = Gitlab.client(endpoint: $conf.get_key(:endpoint), private_token: $conf.get_key(:token))
    run
  else
    puts "WARNING, could not execute BITBAR_GITLAB"
    puts
    puts "make sure '~/.bitbar_gitlab_cnf.yml' exists."
    puts "You might want to run 'gitlab-bitbar-plugin.rb install'"
  end
end
