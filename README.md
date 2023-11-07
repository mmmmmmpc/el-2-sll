# el-2-sll

Tools to convert from EL to SUSE Liberty Linux

Initial build for the Hackweek project:
https://hackweek.opensuse.org/23/projects/use-uyuni-to-migrate-el-linux-to-sll



## Test environment preparation
- Sync the SLL/SLES-ES channels
- Create an activation key with the SLL/SLES-ES channels
- Create a configuration channel with the content of init.sls. The state will:
  - remove `/usr/share/redhat-release`: DONE
  - remove `/etc/dnf/protected.d/redhat-release.conf`: DONE
  - install SLL package: DONE
  - re-install all packages from SLL channels: DONE (missing manually verify if signature have changed)
- Assign the configuration channel to the activation key

### For new minions
- Onboard minion with the activation key
  - Create a bootstrap script using the Activation key
  - Onboard using webUI and select the activation key
- Configuration channel and software channels should be assigned automatically by the activation key
- Apply high state and the minion will be migrate to SLL/SLES-ES
  - The high state apply with apply the configuration channel and migrate the machine to Liberty Linux

### For already registered minions
- Hacked the change channels feature to allow change channel to SLL9 (needs to be refactored, since the code is now hard coding the channel label)
- Assign the Configuration channel
- Apply high state to system
