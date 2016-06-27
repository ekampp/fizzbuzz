require 'pathname'
require 'bundler'

Bundler.require :default
Dotenv.load
$env = String(ENV['RACK_ENV'].presence || 'development').downcase
Bundler.require :default, $env

$root = Pathname.new(Dir.pwd)
$: << $root.to_s

Grape::ActiveRecord.configure_from_file! $root.join("config", "database.yml")
