Midokura Cookbook
===================
This cookbook installs and configures Midokura on CentOS 6 physical and virtual machines. Only package installations are supported. In order to access Midokura repos you will need a support contract which will provide you with the username and password that is necessary.

Requirements
------------

### Attributes
To deploy you must have the following attributes defined for accessing the Midokura repositories:
- node['midkokura']['repo-username']
- node['midkokura']['repo-password']

The full list of attributes can be found in attributes/default.rb

#### Platforms
This cookbook only supports RHEL/CentOS 6 at the time being.

#### Bershelf
A Berksfile is included to allow users to easily download the required cookbook dependencies.
- Install Berkshelf: `gem install berkshelf`
- Install Deps from inside this cookbook: `berks install`

#### Cookbooks
- `java` - configures Java for use by Midokura and its dependencies
- `yum-epel` - used for installing EPEL repository
- `cassandra` - Installs DataStax Cassandra

Contributing
------------

1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write your change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

License and Authors
-------------------
Authors:

Vic Iglesias <vic.iglesias@eucalyptus.com>
