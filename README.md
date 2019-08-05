# ansible-laptop-setup

## <a name="about">About</a>

This is a Ansible playbook which configures my notebook / VM.

## <a name="use">How to use it</a>

### Step 1) Configuring the inventory file

Configure the target system, by editing the ``inventory`` file:

    [local]
    127.0.0.1

    [local:vars]
    ansible_connection=local

    [remote]
    <hostname or IP address, e.g. 108.188.75.107> ansible_ssh_user=<remote user, e.g. jan>

Comment out the local / remote section, depending on your needs.

### Step 2) Configuring the setup_user_vars.yml file

Create / modify the ``setup_user_vars.yml`` file:

    - setup_user: <target user who will use the system, e.g. jan>
    - ssh_user: <remote user, e.g. jan>
    - setup_user_full_name: <target user full name, e.g. Neil Armstrong>
    - setup_user_email: <target user email address, e.g. neil.armstrong@nasa.com>

### (SSH only) Step 3) Enable SSH on the target system

**Attention**: This is not needed when ansible should run on your local host.

Enable SSH by installing openssh-server on your target machine:

    sudo apt install openssh-server

Now, you have to setup the authentication:

* Option A) Setup the public-private key based authentication between your host and target machine, e.g. as mentioned here: https://docs.ansible.com/ansible/latest/user_guide/intro_getting_started.html
* Option B) Alternatively, you can also authenticate via username-password. This is default (via ``--ask-pass`` and ``--ask-become-pass`` in execute.sh).

If host key checking should be disabled, please comment in the option in the ``ansible.cfg`` file

**Attention**: Please ensure that your SSH access is hardened (or just disabled after running ansible).

### Step 4) Run ansible (i.e. modify your target system)

Then run 

    sudo ./execute.sh

or

    sudo ansible-playbook playbook.yml -i inventory -f 10

to execute the playbook on your inventory.

## <a name="todo">TODO's</a>
- [x] Enable dash favorite bar (Nautilus, Firefox, Spotify, VS Code, GitKraken, terminator, Putty, Screenshot, Snappr, VirtualBox)
- [ ] For virtualbox, use third-party repo instead of default repo as the one from Ubuntu repo is very old

