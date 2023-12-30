
echo "Installing rbenv (ruby 3.2.2 + yjit) and rustup"
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
curl -fsSL https://github.com/rbenv/rbenv-installer/raw/HEAD/bin/rbenv-installer | bash
RUBY_CONFIGURE_OPTS="--enable-yjit"
echo "export RUBY_CONFIGURE_OPTS=\"--enable-yjit\"" >> ~/.bashrc
source "$HOME/.cargo/env"
echo "note: --enable-yjit has been added to bashrc and temp terminal path"
echo "'rbenv install 3.2.2 --verbose' to install the latest ruby with yjit"
echo "'rbenv global 3.2.2' to set the latest ruby with yjit as the default"