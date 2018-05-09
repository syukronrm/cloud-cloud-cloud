# Ansible

## 1. Membuat hosts
Membuat file `./hosts` berisi
```
[worker]
worker1 ansible_host=10.151.36.200 ansible_ssh_user=syukronrm ansible_become_pass=sandi
worker1 ansible_host=10.151.36.193 ansible_ssh_user=syukronrm ansible_become_pass=sandi

[master]
10.151.36.194 ansible_ssh_user=syukronrm ansible_become_pass=sandi

```

Setelah itu, install python pada masing-masing remote server.

```bash
sudo apt-get install python
```

Pada server debian, agar bisa menjalankan sudo. Install `sudo`
```bash
sudo apt-get install sudo
```

Setelah itu, masukkan user syukronrm kepada group sudo
```bash
sudo usermod -aG sudo,adm syukronrm
```

Pada semua host, generate ssh key dengan
```bash
ssh-keygen
```

Tambahkan key setiap remote server,
```bash
ssh-copy-id syukronrm@10.151.36.193
ssh-copy-id syukronrm@10.151.36.194
ssh-copy-id syukronrm@10.151.36.200
```

## 2. Setup Debian
```yaml
- hosts: master
  become: yes
  tasks:
    - name: install mysql
      apt: name={{ item }} state=latest update_cache=true
      with_items:
        - mysql-server
      tags:
        - mysql

    - name: run MySQL
      service: name=mysqld state=started enabled=yes
      tags:
      - mysql
      - mysql-service

    - name: install required python MySQLdb lib to create databases and users
      apt: name={{item}} state=present
      with_items:
        - g++
        - python-mysqldb
      tags:
      - mysql
      - mysql-dependencies

    - name: create db user
      mysql_user: name=regal password=bolaubi priv='*.*:ALL' host='%' state=present
      tags:
      - mysql
      - mysql-user
 
    - name: create mysql database
      mysql_db: name=regalq state=present
      tags:
      - mysql
      - mysql-db

    - name: bind mysql remote address
      ini_file: dest=/etc/mysql/mariadb.conf.d/51-bind.cnf
                section=mysqld
                option=bind-address
                value={{item}}
      with_items: 0.0.0.0
      tags:
      - mysql
      - mysql-configure

    - name: restart mysql
      service: name=mysqld state=restarted
```

## 3. Setup worker
```yaml
- hosts: worker
  become: yes
  tasks:
    - name: install deps for apt
      apt: name={{ item }} state=latest update_cache=true
      with_items:
        - python3-apt
        - python-apt

    - name: add php repository
      apt_repository:
        repo: deb http://ppa.launchpad.net/ondrej/php/ubuntu xenial main 


    - name: install nginx, php7, git
      apt: name={{ item }} state=latest force=true
      with_items:
        - nginx
        - git
        - unzip
        - php7.2
        - php7.2-cli
        - php7.2-dev
        - php7.2-sqlite3 
        - php7.2-gd
        - php7.2-curl 
        - php7.2-memcached
        - php7.2-imap 
        - php7.2-mysql 
        - php7.2-mbstring
        - php7.2-xml 
        - php7.2-zip 
        - php7.2-bcmath 
        - php7.2-soap
        - php7.2-readline
        - php7.2-fpm

    - name: download composer
      command: curl -sS https://getcomposer.org/installer -o composer-setup.php

    - name: install composer
      command: php composer-setup.php --install-dir=/usr/local/bin --filename=composer

    - name: clone and install project
      shell: |
        cd /var/www

        git clone https://github.com/udinIMM/Hackathon Hackaton
        cd Hackaton

        rm database/migrations/2018_04_21_175358_add_name_column_users.php

        cp .env.example .env

        php artisan key:generate

        sed -i "s/DB_HOST=/DB_HOST=10.151.36.194/g" .env
        sed -i "s/DB_DATABASE=/DB_DATABASE=regalq/g" .env
        sed -i "s/DB_USERNAME=/DB_USERNAME=regal/g" .env
        sed -i "s/DB_PASSWORD=/DB_PASSWORD=bolaubi/g" .env

        composer install

        php artisan migrate
        
        chown www-data:www-data -R .
        chmod 777 -R .

    - name: config nginx
      copy:
        src: ./nginx/default
        dest: /etc/nginx/sites-available/default

    - name: restart nginx
      service:
        name: nginx
        state: restarted
```

Hapus file `2018_04_21_175358_add_name_column_users.php` agar tidak error keika menjalankan migration.

#### Screenshot
![alt text](imgs/sekrinsut.png "Screenshot")
