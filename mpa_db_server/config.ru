# frozen_string_literal: true

# require 'sinatra'
# require_relative './comic'
# rerun --dir cgmfs -- "puma -C config/puma-nginx.rb"
require 'rubygems'
require 'roda'

require File.expand_path 'mpa_db_server.rb', __dir__

run MPMDBServer