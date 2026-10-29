# -*- mode: ruby -*-
# vim: set ft=ruby :

# Указываем зеркало для скачивания образов
ENV['VAGRANT_SERVER_URL'] = 'https://vagrant.elab.pro'

Vagrant.configure("2") do |config|

  # ============================================
  # ВМ — Ubuntu 22.04
  # ============================================
  config.vm.define "ubuntuserver" do |serv|
    serv.vm.box = "ubuntu/jammy64"
    serv.vm.hostname = "ubuntuserver"
    serv.vm.provider "virtualbox" do |v|
      v.memory = 2048
      v.cpus = 2
    end

    # Оставляем ту же приватную сеть, если она нужна для доступа
    serv.vm.network "private_network", ip: "192.168.50.10", adapter: 2, netmask: "255.255.255.0"

    serv.vm.provision "shell",
      run: "always",
      inline: <<-SHELL

        # Копируем скрипт из общей папки в домашнюю директорию
        cp /vagrant/ps_ax.sh /home/vagrant/ps_ax.sh
        chown vagrant:vagrant /home/vagrant/ps_ax.sh
        chmod +x /home/vagrant/ps_ax.sh

      SHELL
  end
end
