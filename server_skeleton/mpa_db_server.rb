require 'roda'
require_relative 'requires/mpa_db_server_require_all'
require_relative 'logger' #log to log.txt with log(string)
require_relative 'require_dir'
class MPMDBServer < Roda
  PUBLIC_URL_PATH = :static
  plugin :static, ["/css", "/js", "/images", "/fonts", "/favicon.ico"]
  plugin :render, escape_html: false, :escape => false
  plugin :multi_route
  plugin :json
  plugin :json_parser
  plugin :all_verbs
  plugin :hash_routes
  plugin :not_found
  plugin :error_handler
  plugin :slash_path_empty
  #plugin :assets, css: "style.css", js: "script.js", css_opts: {style: :compressed}, js_opts: {compress: true}
  plugin :public
  plugin :shared_vars
  plugin :exception_page
  plugin :halt
  plugin :flash
  plugin :sessions, :secret => 'mpm_db_server3748w5yuieskrhfakgejgKAYUSGDYFHKGD&*R#at3wLKSGFHgfjgklsdfgjkl'

  not_found do
    "route_not_found"
  end
  require_dir './mpm_db_server/routes'
  route do |r|
    log("request path: #{r.path} ; request host: #{r.host}")
    r.public
    r.hash_routes
  end


end
