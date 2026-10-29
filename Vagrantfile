# -*- mode: ruby -*-
# vim: set ft=ruby :

# Указываем зеркало для скачивания образов
ENV['VAGRANT_SERVER_URL'] = 'https://vagrant.elab.pro'

Vagrant.configure("2") do |config|

  # ============================================
  # 1. vpnserver (AlmaLinux 9)
  # ============================================
  config.vm.define "vpnserver" do |serv|
    serv.vm.box = "almalinux/9"
    serv.vm.hostname = "vpnserver"
    serv.vm.provider "virtualbox" do |v|
      v.memory = 2048
      v.cpus = 2
    end

    serv.vm.network "private_network", ip: "192.168.50.10", adapter: 2, netmask: "255.255.255.0"

    serv.vm.provision "shell",
      run: "always",
      inline: <<-SHELL

        # установка пакетов.
        sudo dnf install -y epel-release
        sudo dnf install -y net-tools iperf3 openvpn

        # создание конфигов для tun и tap (сервер)
        sudo mkdir -p /etc/openvpn

        sudo tee /etc/openvpn/server-tun.conf > /dev/null <<'EOF'
dev tun
ifconfig 10.10.10.1 10.10.10.2
secret /etc/openvpn/static.key
status /var/log/openvpn-status-tun.log
log /var/log/openvpn-tun.log
verb 3
cipher AES-256-CBC
EOF

        sudo tee /etc/openvpn/server-tap.conf > /dev/null <<'EOF'
dev tap
ifconfig 10.10.10.1 255.255.255.0
secret /etc/openvpn/static.key
status /var/log/openvpn-status-tap.log
log /var/log/openvpn-tap.log
verb 3
cipher AES-256-CBC
EOF

        # статический ключ (одинаковый на сервере и клиенте)
        sudo tee /etc/openvpn/static.key > /dev/null <<'EOF'
#
# 2048 bit OpenVPN static key
#
-----BEGIN OpenVPN Static key V1-----
64e402ef0ce8d8e87a2842eeff049330
a050605caf47c487486a910419a7cd8b
77b7a7a4ffc1014cfbf9cadfeba97ce6
be0736051f1d4b2a7ccbfb6ef6e5b1e6
c550d9ac2e811dd6b11e77fd363ab9a3
ca5019b210e8bf018853d8cec9aa70d1
f763c5f992564c65771919a35079aa7c
9bde057e43f1877dc819568b0f0841a9
e9b9af801d20bb75379a1901dfca01a3
9df193def4275c0e8e233dd40a6f95a1
04c89cdc940daae4b7117fb26f37b862
8d4ba6d9dfa35fc46cc75937842c5be6
7292aa6f1fb1d7b1b0754224ac13be25
ac1fc41f3c747898059a7de61611489a
ee363fdd5f24247ffe8a665ab851b831
143f254a3516ca21b2057274fc025826
-----END OpenVPN Static key V1-----
EOF

        sudo chmod 600 /etc/openvpn/static.key
        sudo chmod 644 /etc/openvpn/server-tun.conf /etc/openvpn/server-tap.conf

        # Копируем скрипт из общей папки в домашнюю директорию
        cp /vagrant/setup_openvpn.sh /home/vagrant/setup_openvpn.sh
        chmod +x /home/vagrant/setup_openvpn.sh
        chown vagrant:vagrant /home/vagrant/setup_openvpn.sh

    SHELL
  end

  # ============================================
  # 2. vpnclient (AlmaLinux 9)
  # ============================================
  config.vm.define "vpnclient" do |client|
    client.vm.box = "almalinux/9"
    client.vm.hostname = "vpnclient"
    client.vm.provider "virtualbox" do |v|
      v.memory = 2048
      v.cpus = 2
    end

    client.vm.network "private_network", ip: "192.168.50.11", adapter: 2, netmask: "255.255.255.0"

    client.vm.provision "shell",
      run: "always",
      inline: <<-SHELL

        # установка пакетов.
        sudo dnf install -y epel-release
        sudo dnf install -y net-tools iperf3 openvpn

        # создание конфигов для tun и tap (клиент)
        sudo mkdir -p /etc/openvpn

        sudo tee /etc/openvpn/client-tun.conf > /dev/null <<'EOF'
dev tun
remote 192.168.50.10
ifconfig 10.10.10.2 10.10.10.1
secret /etc/openvpn/static.key
status /var/log/openvpn-status-tun.log
log /var/log/openvpn-tun.log
verb 3
cipher AES-256-CBC
EOF

        sudo tee /etc/openvpn/client-tap.conf > /dev/null <<'EOF'
dev tap
remote 192.168.50.10
ifconfig 10.10.10.2 255.255.255.0
secret /etc/openvpn/static.key
status /var/log/openvpn-status-tap.log
log /var/log/openvpn-tap.log
verb 3
cipher AES-256-CBC
EOF

        # тот же самый ключ, что и на сервере
        sudo tee /etc/openvpn/static.key > /dev/null <<'EOF'
#
# 2048 bit OpenVPN static key
#
-----BEGIN OpenVPN Static key V1-----
64e402ef0ce8d8e87a2842eeff049330
a050605caf47c487486a910419a7cd8b
77b7a7a4ffc1014cfbf9cadfeba97ce6
be0736051f1d4b2a7ccbfb6ef6e5b1e6
c550d9ac2e811dd6b11e77fd363ab9a3
ca5019b210e8bf018853d8cec9aa70d1
f763c5f992564c65771919a35079aa7c
9bde057e43f1877dc819568b0f0841a9
e9b9af801d20bb75379a1901dfca01a3
9df193def4275c0e8e233dd40a6f95a1
04c89cdc940daae4b7117fb26f37b862
8d4ba6d9dfa35fc46cc75937842c5be6
7292aa6f1fb1d7b1b0754224ac13be25
ac1fc41f3c747898059a7de61611489a
ee363fdd5f24247ffe8a665ab851b831
143f254a3516ca21b2057274fc025826
-----END OpenVPN Static key V1-----
EOF

        sudo chmod 600 /etc/openvpn/static.key
        sudo chmod 644 /etc/openvpn/client-tun.conf /etc/openvpn/client-tap.conf

    SHELL
  end
end
