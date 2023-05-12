# Virtual kubernetes cluster
### virtualbox machines for kubernetes installation
#### Make help improve your skills in kubernetes in your local machine!

### Step 0: Prerequisite

Your need install vagrant and virtualbox in your host machine

### Step 1: Download debian vagrant box

Download box bento/debian-11 for virtualbox from [vagrantup](https://app.vagrantup.com/bento/boxes/debian-11.5 "vagrantup") and move it to the project folder with name "debian":

```
mv ~/Downloads/a2a5f4df-eba7-4c0c-88e4-7ff6d02d5ada /path/to/project/debian
```

### Step 2: Add box to vagrant

For windows (in power shell):

``vagrant box add bento/debian-11 debian``

For linux/unix witn Make:

``make build``

### Step 3: Launch the configuration

Open virtualbox.

For windows (in power shell):

``vagrant up --provider=virtualbox``

For linux/unix witn Make:

``make``

