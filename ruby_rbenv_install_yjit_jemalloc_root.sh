
echo "INSTALLER SCRIPT for: rbenv (ruby 3.2.2 (current) + yjit + jemalloc) and rustup"
echo "NOTE: THIS MODIFIES YOUR ~/.bashrc FILE and 'source' is used"
echo '---------------------------------------------------------------------'
echo 'installing jemalloc (required for yjit)'
apt install libjemalloc-dev
echo 'INSTALLING rust (default options are the only necessary ones...)'
echo '---------------------------------------------------------------------'
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
echo 'DONE.'
echo 'INSTALLING rbenv (rub + yjit + jemalloc)'
echo '---------------------------------------------------------------------'
curl -fsSL https://github.com/rbenv/rbenv-installer/raw/HEAD/bin/rbenv-installer | bash
echo 'setting RUBY_CONFIGURE_OPTS="--enable-yjit --with-jemalloc" to path and ~/.bashrc'
RUBY_CONFIGURE_OPTS="--enable-yjit --with-jemalloc"
echo 'eval "$(~/.rbenv/bin/rbenv init - bash)"' >> ~/.bashrc
echo 'export RUBY_CONFIGURE_OPTS="--enable-yjit --with-jemalloc"' >> ~/.bashrc
echo 'DONE.'
echo '"Sourcing $HOME/.cargo/env" (rust)'
source "$HOME/.cargo/env"
echo "DONE."
echo "Additional packages..."
sudo apt-get install autoconf bison patch build-essential libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libgmp-dev libncurses5-dev libffi-dev libgdbm6 libgdbm-dev libdb-dev uuid-dev
echo "DONE."
echo "---------------------------------------------------------------"
echo "SETUP END NOTES:"
echo "note: --enable-yjit has been added to bashrc and temp terminal path"
echo "RBENV COMMANDS LIST SUMMARY"
echo "2 COMMANDS TO EXECUTE (you may need to restart your terminal):"
echo "'rbenv install 3.2.2 --verbose' (to install the latest ruby with yjit + jemalloc)"
echo "'rbenv global 3.2.2' (to set the latest ruby with yjit as the global default)"
echo "---------------------------------------------------------------"
echo "'rbenv global' to check the current global ruby version"
echo "'rbenv versions' to check all installed ruby versions"
echo "'rbenv uninstall 3.2.2' to uninstall ruby 3.2.2"
echo "'rbenv uninstall --force 3.2.2' to uninstall ruby 3.2.2 and all associated gems"
echo "'rbenv rehash' to update rbenv shims"
echo "'rbenv version' to check the current ruby version"
echo "'rbenv version-name' to check the current ruby version"
echo "'rbenv which ruby' to check the current ruby path"
echo "'rbenv which gem' to check the current gem path"
echo "'rbenv which bundle' to check the current bundle path"
echo "'rbenv which irb' to check the current irb path"
echo "'rbenv which rails' to check the current rails path"
echo "'rbenv which rake' to check the current rake path"
echo "'rbenv which rdoc' to check the current rdoc path"
echo "'rbenv which rspec' to check the current rspec path"
echo "'rbenv which rubocop' to check the current rubocop path"
echo "---------------------------------------------------------------"