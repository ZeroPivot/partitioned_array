rbenv init
RUBY_CONFIGURE_OPTS="--enable-yjit"
rbenv install 3.2.2
rbenv global 3.2.2
echo "updating rubygems and system"
gem update --system && gem update
echo "installing bundler"
gem install bundler
echo "done. you might have to restart your terminal session for the changes to take effect"