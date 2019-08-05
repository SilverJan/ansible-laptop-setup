If you want to develop in this playbook, use the following hints:

## Facts

Facts are currently created in the role "sysinfo". Search there for set_fact commands.

## Debugging

### Debugging a playbook run

TBD

### Debugging variables

To verify the vaue of a variable, add the following task into a main.yml:

    - debug:
        var: <variable>
        #verbosity: 2

More information on debugging: https://docs.ansible.com/ansible/latest/modules/debug_module.html

### Debugging facts

To check which facts ar generated for your target inventory, run

    sudo ansible <hostname> -m setup
    # example for localhost
    sudo ansible localhost -m setup