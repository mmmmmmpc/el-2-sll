{% if grains['os_family'] == 'RedHat' %}

# should we touch a file to check if the uyuni/suma migration was already done?

{% set release = grains.get('osmajorrelease', None)|int() %}
{% set osName = grains.get('os', None) %}

# EL 9 and higher
{% if release == 9 %}
{% if not salt['file.search']('/etc/os-release', 'SUSE Liberty Linux') %}

/usr/share/redhat-release:
  file.absent

/etc/dnf/protected.d/redhat-release.conf:
  file.absent

{% if osName == 'Rocky' %}
/usr/share/rocky-release/:
  file.absent

remove_release_package:
  cmd.run:
    - name: "rpm -e --nodeps rocky-release"

{% endif %}

{% if osName == 'AlmaLinux' %}
/usr/share/almalinux-release/:
  file.absent

remove_release_package:
  cmd.run:
    - name: "rpm -e --nodeps almalinux-release"
{% endif %}

{% if osName == 'OEL' %}
/usr/share/oraclelinux-release/:
  file.absent

remove_release_package:
  cmd.run:
    - name: "rpm -e --nodeps oraclelinux-release"
{% endif %}

install_package_9:
  pkg.installed:
    - name: sll-release
    - refresh: True

re_install_from_SLL:
  cmd.run:
    - name: "dnf -x 'venv-salt-minion' reinstall '*' -y >> /var/log/dnf_sll_migration.log"
    - require:
      - pkg: install_package_9

{% endif %} # end if for search

{% elif release <= 8 %} # end else if of rhel 9

{% if not salt['file.search']('/etc/os-release', 'SLES Expanded Support') %}

/usr/share/redhat-release:
  file.absent

#/etc/dnf/protected.d/redhat-release.conf:
#  file.absent

install_package_lt9:
  pkg.installed:
    - name: sles_es-release-server
    - refresh: True

re_install_from_SLL:
  cmd.run:
    - name: "yum -x 'venv-salt-minion' -x 'salt-minion' reinstall '*' -y >> /var/log/yum_sles_es_migration.log"
    - require:
      - pkg: install_package_lt9

{% endif %} # end if for search
{% endif %} # end if for release <= 8

{% endif %} # endif of rhel family
