DEBIAN_FRONTEND=noninteractive

echo "Starting system update..."
apt-get update
apt-get upgrade -y

# getting around some very weird bugs with this
apt-get update
sleep 10

echo "Installing packages..."
apt-get install -y wget unzip curl
