# -*- mode: ruby -*-
# vim: set ft=ruby :

ENV['VAGRANT_SERVER_URL'] = 'https://vagrant.elab.pro'

MACHINES = {
  :ubuntuserver => {
    :box_name => "ubuntu/jammy64",
    :vm_name => "ubuntuserver",
    :ip => "192.168.50.10",
    :memory => 2048,
    :cpus => 2
  }
}

Vagrant.configure("2") do |config|

  MACHINES.each do |boxname, boxconfig|

    config.vm.define boxname do |box|
   
      box.vm.box = boxconfig[:box_name]
      box.vm.hostname = boxconfig[:vm_name]
      
      # В оригинальном файле было добавление диска, но для нашей задачи
      # он не нужен, поэтому я закомментировал эту строку, чтобы не 
      # создавать лишних сущностей. Если хотите - раскомментируйте.
      # box.vm.disk :disk, size: "35GB", primary: true

      box.vm.provider "virtualbox" do |v|
        v.memory = boxconfig[:memory]
        v.cpus = boxconfig[:cpus]
      end

      box.vm.network "private_network", ip: boxconfig[:ip]
      
      # Проброс порта для SSH (чтобы не конфликтовать с другими ВМ, 
      # если у вас они запущены, оставляем 2222)
      box.vm.network "forwarded_port", guest: 22, host: 2222, id: "ssh", auto_correct: true

      # Провижининг: копируем скрипт и делаем его исполняемым
      box.vm.provision "shell", inline: <<-SHELL
        cp /vagrant/ps_ax.sh /home/vagrant/ps_ax.sh
        chown vagrant:vagrant /home/vagrant/ps_ax.sh
        chmod +x /home/vagrant/ps_ax.sh
      SHELL
    end
  end
end
