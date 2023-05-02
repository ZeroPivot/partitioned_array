echo "Installing ruby 3.2.2 (assuming ubuntu/debian etc; ctrl+c to cancel asap if there is a newer version; new as of 2023-05-02)"
echo "..."
echo "installing rust"
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
echo "installing additional packages that might be useful"
sudo apt-get install gtk-doc-tools gobject-introspection glib2.0 libvips42 libvips-dev imagemagick libmagickwand-dev libfreeimage3 libfreeimage-dev jpegoptim optipng
sudo apt-get install autoconf bison build-essential libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm6 libgdbm-dev libdb-dev
echo "installing rbenv"
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
echo 'eval "$(~/.rbenv/bin/rbenv init - bash)"' >> ~/.bashrc
source ~/.bashrc
sudo apt-get install autoconf bison patch build-essential libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libgmp-dev libncurses5-dev libffi-dev libgdbm6 libgdbm-dev libdb-dev uuid-dev


echo "installing ruby-build"
git -C "$(rbenv root)"/plugins/ruby-build pull
echo "..."
echo ""
echo "installing ruby 3.2.2"

echo "(setting up YJIT path first)"
echo "..."
