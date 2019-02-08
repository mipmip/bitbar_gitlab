class GitlabBitbarLibConfig

  def initialize
    @config_file= File.expand_path('~/.bitbar_gitlab_cnf.yml')
    load_config if exists?
  end

  def save_init init_conf
    File.open(@config_file, 'w') { |file| file.write(init_conf.to_yaml) }
  end

  def exists?
    true if File.exists? @config_file
  end

  def delete
    File.delete @config_file
  end

  def load_config
    @config = YAML.load_file(@config_file)
  end

  def save_config
    File.open(@config_file, 'w') do |f|
      f.write(@config.to_yaml)
    end
  end

  def get_key sym
    @config[sym.to_s.upcase] if @config.key?(sym.to_s.upcase)
  end

  def set_key sym, val
    @config[sym.to_s.upcase] = val
    save_config
  end

  def toggle_on? key
    if @config['TOGGLE_'+key.to_s.upcase] and @config['TOGGLE_'+key.to_s.upcase] !=0
      true
    else
      false
    end
  end

  def key_is_set key
    if get_key(key) and get_key(key) != 0
      true
    end
  end




end
