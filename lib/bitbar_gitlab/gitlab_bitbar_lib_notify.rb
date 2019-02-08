def notify option_string
  if File.exists? "/usr/local/bin/terminal-notifier"
    system "/usr/local/bin/terminal-notifier #{option_string}"
  end
end
