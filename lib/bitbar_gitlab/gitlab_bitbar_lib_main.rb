def run_main

  puts "| templateImage=iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAAAXNSR0IArs4c6QAAAAlwSFlzAAAWJQAAFiUBSVIk8AAAAVlpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IlhNUCBDb3JlIDUuNC4wIj4KICAgPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4KICAgICAgPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIKICAgICAgICAgICAgeG1sbnM6dGlmZj0iaHR0cDovL25zLmFkb2JlLmNvbS90aWZmLzEuMC8iPgogICAgICAgICA8dGlmZjpPcmllbnRhdGlvbj4xPC90aWZmOk9yaWVudGF0aW9uPgogICAgICA8L3JkZjpEZXNjcmlwdGlvbj4KICAgPC9yZGY6UkRGPgo8L3g6eG1wbWV0YT4KTMInWQAAA/ZJREFUWAm1lsmPTFEUxp82dwwhSFiIIWgSTUxhR6TpGBckhrDBhoUpbBA7O0PC32AIVoZIhJAYEiKmhWGnJcQ8RczT93t1vsrt6iqlOvElX91zz/nOOffed9/rzrK26JC4Ujtx12SmNVK7bJGO4d2gcV3Y9pVNqOJ07lrpNtZS77nEjyOh6qpDV25w7iMFX5YTpD6vdrKcv4PjQlCXCv/Rdk5j1KLmlMh1r8wi/LYXhohhftiOJaGqpnNcgwTXdqxVER/XHXl9AtdD4VirhCoTN7mW1LtbqZ7FHDnNfwWxR4vAmsLs77/WNkjmzfwMe3yk5o/BQo8+rh8SQTC3MLRrAc79rhosACwoDFmrU/WEI2fFXgD25UjwImP618HaS1KV1rsRme5Z3BlH7eNKHwGLGR5JLhzTsoM1wxRl59RM6zEfI4I6xE5ozl1Z9lkjxwWxeVazRNBV7FSFaECTiLa0HjH3ynt7AfcU8AmUjrfJqhG3pC+t4/n9qFXn5zBYjh3hxIfQ4AQ+ijfFLmIa07QNyP8mThB7iJyk+8gs5u+S3YIDbBP35FblnyMKeQfVxqOVy+SR3frdnmouaELRZeHsrtHPulv4ZmpE80XkcpUjMTQ8f0Cu61ATLBHRXBRzDNHvVxEnRRtEQCLw8dXLfiKi41gZU9r3VH60wLmuNUo+epBHz6FcwDkiz5bVIzwhdhZ5/Ygjxv9JPCsCXqtS2IcGLTnkUoNars1IL3rSOzsnIkTkkzgmG3ABAUmALyVa7wLbtM9/cJzjGkdDSw96kXdezHeTFuUGM99KUOA0fJQ9ZT8XifvIU/uF/L1EQA65YIuIzrW9WHzZ+ghakH61ZiAQKOSdHJSNNi1i+5D8AK2bT5eN3nW9CHwbxBxT9dsiurALvpVvQK4ofAUxF4nWMab2YgSCv4b9Zb8RrXHdx/JNE3N4pbwy7MBFuUjYV0Xgx9BH9muRmHeFTaO+IrD2imxiroV9WPSr7d7FS6ZYtkr0SvkCknRABE7kkuJHZ+1x2cCa/bLRuAYXb7Vo+JJ6nr8udo6Q96ZIAX9cVhaVWbY0YukClifxFRF3Ln8XRkacHryaFVE8Fin2iiwCcnkaRTBQfC869kH2IBGMFf06E9+HM5DWtq/s6BtPkP9qXooUeyjWi+Ck6AWcyj1Zxuf2QfjJmRd+hrRm4q5scpG84n6yaUJDN+OueAFrZAMv6rRs3gBADV/K3FHrjxdB3iaRpjuZCFwsPkhgh0hsM5NAmmtfu0YujS/ORNmvxGaRnZ4RZ4v4Jokg1Rc8FX5rPRp2xM3vLbJTLiN4JnJh34nWyPw/8KtK9aagO6Ux+/7LyBGnp4ftR1RTwz+EnjyMz43L0gAAAABJRU5ErkJggg=="

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

