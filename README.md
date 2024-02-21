# Commands

```
git clone git@github.com:kodecraft-pau/nomad.git
cd nomad/
vagrant up

nomad fmt wasmcloud.nomad
nomad validate wasmcloud.nomad
nomad plan wasmcloud.nomad
nomad run wasmcloud.nomad
```
```
vagrant ssh
sudo systemctl status --no-pager nomad
sudo systemctl status --no-pager consul
logout
```

### nomad dashboard
* http://localhost:4646

### consul dashboard
* http://localhost:8500/
