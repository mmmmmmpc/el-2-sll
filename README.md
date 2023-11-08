# Convert from Enterprise Linux clones to SUSE Liberty Linux using SUSE Manager

Tools to convert from any EL clone (RHEL / Rocky / Alma) to SUSE Liberty Linux using SUSE Manager

Initial build for the Hackweek project:
https://hackweek.opensuse.org/23/projects/use-uyuni-to-migrate-el-linux-to-sll

## Deploy SUSE Manager
- Requirement: Use SUSE Manager 4.3
- Get Software
  - In a cloud provider search in the marketplace for SUSE Manager
  - If you want to use a VM of physical hardware go to [SUSE Manager Dowloads](https://www.suse.com/download/suse-manager/)
    - Install SUSE Manager following [Documentation](https://documentation.suse.com/suma/4.3/en/suse-manager/installation-and-upgrade/install-server-unified.html)
  - Complete initial SUSE Manager setup following [Documentation](https://documentation.suse.com/suma/4.3/en/suse-manager/installation-and-upgrade/server-setup.html)

## Configuring SUSE Manager
- Provide SUSE Customer Center credentials
  - Log in in [SUSE Customer Center](https://scc.suse.com)
    - Go to `My Organization`, select your organization
    - Go to `Users` -> `Organization Credentials` and copy your Organization Username and Password
  - In your own instance of SUSE Manager
    - Go to `Admin` -> `Setup Wizard` -> `Organization Credentials`
    - Click on `Add new credential` An use the Username and Paswword provided in SCC and obtained in previous step
- Sync the SLL/SLES-ES channels in SUSE Manager
  - Go to `Admin` -> `Setup Wizard` -> `Products`
  - Select the SUSE Liberty Linux Channels that you will use:
    - EL7: `SUSE Linux Enterprise Server with Expanded Support 7 x86_64`
    - EL8: `RHEL or SLES ES or CentOS 8 Base`
    - EL9: `RHEL and Liberty 9 Base`
  - Click on th top right button `+ Add products`
  - You can check progress by accessing the SUSE Manager machine via SSH and monitoring the logs using `tail -f /var/log/rhn/reposync/*`
- Create one Activation Key per SUSE Liberty Linux channel
  - Note: Activation Keys are the way to register systems and assign them to the software and configuration channels corresponding to them
  - Go to `Systems` -> `Activation Keys` and click on the top right message `+ Create key`
  - Then, to the new Activation Key, add the following content: 
    - `Description`: with some tech describing the acitvation key
    - `Key`: With the identifier for the key, for example `el9-default` for your EL9 systems
      - Note: Keis will have a nimeric prefix depending ont he organization so that there are not to equal keys in the same SUSE Manager
    - `Usage`: Leave blank
    - `Base Channel`: Select one base channel. Depending on your EL version the base channel will be:
        - EL7: `RHEL x86_64 Server 7`
        - EL8: `RHEL8-Pool for x86_64`
        - EL9: `EL9-Pool for x86_64`
    - `Child Channel`
      - Use `include recommended` where available or select all if unavailable
    - `Add-On system type`: Leave all blank
    - `Contact Method`: Default
    - `Universal Default`: Leave unchecked
    - Click on `Create Activation Key`
- Create a configuration channel to automate the "liberation" process
  - Go to `Configuration` -> `Channels` and click on the top right `+ Create State Channel`
    - Note: This will create a channel that will run Salt States in your system. Later on we will assign it directly to an Activation Key to automatically proceed with the conversion to SUSE Liberty Linux. It could also be assigned to already registered systems as described below
    - `Name`: provide a name to the channel, for example `Convert EL 2 SLL`
    - `Label`: provide a label to the channel, for example `el-2-sll`
    - `Description`: provide some descriptive text
    - `SLS Contents`: In here you have to copy the contents from the [init.sls](init.sls) file in this repository and paste them in the box
    - Once completed all the stepsm, click on `Create Config State Channel` and you will have the channel created
  - Note: with the contents of init.sls in this repository The state will:
    - remove `/usr/share/redhat-release`: DONE
    - remove `/etc/dnf/protected.d/redhat-release.conf`: DONE
    - install SLL package: DONE
    - re-install all packages from SLL channels: DONE (missing manually verify if signature have changed)
- Assign the configuration channel to the activation key
  - Go to `Systems` -> `Activation Keys` 
  - Select the Activation Key, for example `el9-default` for your EL9 systems
    - In the Activation Key page go to `Configuration` -> `Subscribe to Channel`
    - Select the Channel name, for example `el-2-sll` and click on the low right button `Continue`
  - Note: Now, when registering any system with this Activation Key, it will automatically subscribe it to the right channels and, by "applying high state", run the conversion to SUSE Liberty Linux.
  
### Registering a new system to SUSE Manager and proceed to the conversion
- There are two wais to onboard, or register, a new system (a.k.a. minion) with the activation key
  - Onboarding a new system using webUI and selecting the activation key
    - Note: This is intended for a one-off registration or for testing purposes
    - Go to `Systems` -> `Bootstraping` 
      - In the `Bootstrap Minions` page fill the entries
      - Note: this will start an SSH connection to the system and run the bootstrap script to register it to SUSE Manager
      - `Host`: Hostname of the system to onboard
      - `SSH Port`: Leave blank to use default, which is `22`
      - `User`: type user or leave blank for `root`
      - `Authentication Method`: Select if you want to use `password` or provide a `SSH Private Key`
        - `Password`: If this was selected please provide the password to access the system
        - `SSH Private Key`: If this was selected please provide the file with the private key 
          - `SSH Private Key Passphrase`: In case a private key was provided that requires a passphrase to unlock, please provide it here.
      - `Activation Key`: Select from the menu the Activation key to be used, for example `el9-default`.
      - `Reactivation Key`: Leave blank it wont be used here
      - `Proxy`: Leave as `None` as it is used for the SUSE Manager specific proxies.
      - Click on the `+ Bootstrap` button to start the registration
      - Note: A message will show in the top of the page stating that the system is being registered, or "bootstraped" in SUSE Manager parlance.
  - Create a bootstrap script using the Activation key
    - Note: This is intended to be used for mass registration 
- Configuration channel and software channels should be assigned automatically by the activation key
- Apply high state and the minion will be migrate to SLL/SLES-ES
  - The high state apply with apply the configuration channel and migrate the machine to Liberty Linux

### For already registered minions
- Note: The channel could be assigned to any already registered system on the system's page in `States` -> `Configuration Channels`
- Hacked the change channels feature to allow change channel to SLL9 (needs to be refactored, since the code is now hard coding the channel label) - https://github.com/rjmateus/uyuni/tree/uyuni_hackweek23_rhel_migration
- Assign the Configuration channel
- Apply high state to system


## Version testing status


| OS version  | Status  |
| ----------- | ------- |
| Rhel 9      | working |
| Rocky 9     | working |
| Alma 9      | working |
| Oracle 9    | |
| Rhel 8      | |
| Rocky 8     | |
| Alma 8      | |
| Oracle 8    | |
| Rhel 7      | |
| Oracle 7    | |
| Oracle 7    | |
