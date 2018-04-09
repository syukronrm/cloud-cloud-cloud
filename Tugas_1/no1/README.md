## Persiapan Box

Gunakan box `hashicorp/precise64`.
```rb
  config.vm.box = "hashicorp/precise64"
```

## Provisioning
Tambahkan script dibawah
```rb
  config.vm.provision "shell", inline: <<-SHELL
    useradd -d /home/awan -m -s /bin/bash awan
    echo -e "buayakecil\nbuayakecil" | passwd awan
  SHELL
```

## Deploy
```bash
$ vagrant up --provision
```
