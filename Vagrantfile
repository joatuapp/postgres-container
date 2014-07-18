# -*- mode: ruby -*-
# vi: set ft=ruby :
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.define "postgres" do |pg|
    pg.vm.provider "docker" do |d|
      d.name = 'postgres'
      d.build_dir = "."
    end
  end
end
