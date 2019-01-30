def shellwrap
  "#{CONFIG['EXE_UTIL_DIR']}/shellwrap.sh"
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

def pipeline_focus_menu pr, level, in_focus = false

    data = []
    labels = ['id', 'status','web_url']
    $gitlab.pipelines(pr.to_hash['id'].to_s,{per_page:3, page:1, state: 'running'}).collect do |iss|

      d = []
      labels.each do |l|
        d << iss.to_hash[l].to_s
      end

      data << d
    end

    i=0

    data.each do |d|
      i+=1

      puts "#{indent level}#{d[0]} #{d[1]} | href=#{d[2]}"
    end
end

def pipeline_menu pr, level, in_focus = false

    data = []
    labels = ['id', 'status','web_url']
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

      puts "#{indent level}#{d[0]} #{d[1]} | href=#{d[2]}"
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

def toggle_on? key
  if CONFIG['TOGGLE_'+key.upcase] and CONFIG['TOGGLE_'+key.upcase] !=0
    true
  else
    false
  end
end

def toggle_line level, key, on_text, off_text

  if CONFIG['TOGGLE_'+key.upcase] && CONFIG['TOGGLE_'+key.upcase]!=0
    text=off_text
    status=0
  else
    text=on_text
    status=1
  end

  puts "#{indent level}#{text} | bash=#{shellwrap} param1=set param2=TOGGLE_#{key.upcase} param3=#{status.to_s} terminal=false refresh=true"
end


