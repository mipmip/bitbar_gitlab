def run_main

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

