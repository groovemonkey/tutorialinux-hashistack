DEBIAN_FRONTEND=noninteractive

echo "Starting system update..."
apt-get update && apt-get upgrade -y

echo "Installing packages..."
apt-get install -y wget unzip curl
