require 'relative_time'

def shellwrap
  "#{$conf.get_key :exe_util_dir}/shellwrap.sh"
end

def project_menu pr, level, in_focus = false
  i=0
  data = []
  labels = ['iid', 'title','web_url', 'labels']

  $gitlab.issues(pr.to_hash['id'].to_s,{per_page:9999, state: 'opened'}).collect do |iss|

    d = []
    labels.each do |l|
      if l=='labels'
        iss.to_hash[l].each do |lbl|
          if lbl.include? "impact:"
            d <<  lbl.gsub('impact: ', "I").gsub(' ','').gsub('uur','')
          end
        end
      elsif l=='iid'
        d << "#" + iss.to_hash[l].to_s
      else
        d << iss.to_hash[l].to_s
      end
    end

    data << d
  end

  puts "#{indent level}New issue | href=#{pr.to_hash['web_url']}/issues/new"

  focus_line level, in_focus, pr.to_hash['id'].to_s

  puts "#{indent level}---"

  data.each do |d|
    i+=1

    puts "#{indent level}#{d[0]} #{d[1]} #{d[3]}"
    puts "#{indent (level+1)}Copy | bash=#{shellwrap} param1=copy param2=\"#{d[0]} #{d[1]} #{d[3]}\" terminal=false"
    puts "#{indent (level+1)}Open issue | href=#{d[2]}"
  end
end

def pipeline_color status
  if status == 'failed'
    'color=red'
  elsif status == 'success'
    'color=green'
  elsif status == 'running'
    'color=blue'
  else
    'color=black'
  end
end

def pipeline_text status
  if status == 'success'
    'passed'
  elsif status == 'running'
    'is running'
  else
    status
  end
end

def pipeline_focus_menu pr, level, in_focus = false

  require "pp"
    data = []
    labels = ['id','status','web_url']
    $gitlab.pipelines(pr.to_hash['id'].to_s,{per_page:3, page:1, state: 'running'}).collect do |iss|

      more = $gitlab.pipeline(pr.to_hash['id'].to_s,iss.to_hash['id'] )

      #PP.pp (Time.now - Time.parse(more.to_hash['finished_at'])).to_i

      d = []
      labels.each do |l|
        d << iss.to_hash[l].to_s
      end

      if more.to_hash['finished_at']
        d << RelativeTime.in_words(Time.now - (Time.now - Time.parse(more.to_hash['finished_at'])).to_i)
      else
        d << ''
      end

      data << d
    end

    i=0

    data.each do |d|
      if i == 0
        if $conf.get_key(:last_job_id) == d[0] and $conf.get_key(:last_job_status) != d[1]
          if d[1] == 'success'
            notify "-title 'GitLab Pipeline Passed' -message '#{d[0]} passed' -open '#{d[2]}'"
          elsif d[1] == 'failed'
            notify "-title 'GitLab Pipeline Failed' -message '#{d[0]} failed' -open '#{d[2]}'"
          end
        end

        $conf.set_key :last_job_id, d[0]
        $conf.set_key :last_job_status, d[1]

      end

      i+=1

      puts "#{indent level}job #{d[0]} #{pipeline_text d[1]} #{d[3]}| href=#{d[2]} #{pipeline_color d[1]}"
    end
end

def pipeline_menu pr, level, in_focus = false

    project_info = $gitlab.project(pr.to_hash['id'].to_s)
    return unless project_info.to_hash['jobs_enabled']

    labels = ['id','status','web_url']
    data = []

    $gitlab.pipelines(pr.to_hash['id'].to_s,{per_page:3, page:1, state: 'running'}).collect do |iss|
      d = []
      labels.each do |l|
        d << iss.to_hash[l].to_s
      end
      data << d
    end

    i=0

    if in_focus
      puts "#{indent level}Clear focus | bash=#{shellwrap} param1=set param2=pipeline_focus param3=0 terminal=false refresh=true"
    else
      puts "#{indent level}Set Focus | bash=#{shellwrap} param1=set param2=pipeline_focus param3=#{pr.to_hash['id']} terminal=false refresh=true"
    end
    puts "#{indent level}---"

    data.each do |d|
      i+=1

      puts "#{indent level}#{d[0]} #{d[1]} | href=#{d[2]} #{pipeline_color d[1]}"
    end
end


def focus_line level, in_focus, project_id
  if in_focus
    puts "#{indent level}Clear focus | bash=#{shellwrap} param1=set param2=project_focus param3=0 terminal=false refresh=true"
  else
    puts "#{indent level}Set Focus | bash=#{shellwrap} param1=set param2=project_focus param3=#{project_id} terminal=false refresh=true"
  end
end


def indent i
  scores = ''
  i.times do
    scores << '--'
  end
  scores
end

def toggle_line level, key, on_text, off_text

  if $conf.toggle_on? key
  #if CONFIG['TOGGLE_'+key.upcase] && CONFIG['TOGGLE_'+key.upcase]!=0
    text=off_text
    status=0
  else
    text=on_text
    status=1
  end

  puts "#{indent level}#{text} | bash=#{shellwrap} param1=set param2=TOGGLE_#{key.upcase} param3=#{status.to_s} terminal=false refresh=true"
end


