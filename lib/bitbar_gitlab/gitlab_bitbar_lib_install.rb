def run_install

  puts "Installing BitBar Gitlab Plugin by Pim Snel"

  if $conf.exists?
    $conf.try_exe_dir_exists
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

    newconf['EXE_UTIL_DIR'] = $conf.exe_dir

    puts
    puts "writing configuration file..."
    puts
    $conf.save_init newconf
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
  File.symlink($conf.exe_file, File.expand_path($conf.get_key :plugin_folder)+'/gitlab-bitbar-plugin.rb')
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

