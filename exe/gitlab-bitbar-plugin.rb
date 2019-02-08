#!/usr/bin/env ruby

require "bundler/setup"
require "bitbar_gitlab"
require 'yaml'
require 'gitlab'

$conf = GitlabBitbarLibConfig.new __FILE__

if ARGV[0]=='install'

  run_install
  install_test_gitlab_connection
  install_bitbar_symlinks

elsif ARGV[0]=='set'
  $conf.set_key ARGV[1].to_sym, ARGV[2].to_i
else

  $conf.missing_warning unless $conf.exists?
  $gitlab = Gitlab.client(endpoint: $conf.get_key(:endpoint), private_token: $conf.get_key(:token))
  $conf.try_exe_dir_exists
  run_main
end
