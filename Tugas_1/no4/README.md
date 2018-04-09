## Persiapan Box

Gunakan box `hashicorp/precise64`.
```rb
  config.vm.box = "hashicorp/precise64"
```

## Provisioning
Tambahkan script dibawah
```rb
  config.vm.provision "shell", inline: <<-SHELL
    apt-get update
    apt-get install -y squid bind9
  SHELL
```

## Deploy
```bash
$ vagrant up --provision
```