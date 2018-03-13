cd ~
wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb
sudo dpkg -i erlang-solutions_1.0_all.deb
sudo apt-get update
sudo apt-get install -y esl-erlang elixir

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8

echo -e "Y\n" | mix local.hex
echo -e "Y\n" | mix archive.install https://github.com/phoenixframework/archives/raw/master/phx_new-1.3.0.ez
echo -e "Y\nY\n" | mix phx.new --no-ecto --no-brunch testserver

cd ~/testserver
mix local.rebar --force 
echo "Y\n" | mix phx.server &


