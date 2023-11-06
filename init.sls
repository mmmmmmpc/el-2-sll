/tmp/testing-salt:
  file.touch

/usr/share/redhat-release:
  file.absent
  
/etc/dnf/protected.d/redhat-release.conf:
  file.absent

{% if grains['os_family'] == 'RedHat' and grains['osmajorrelease'] < 9 %}
install_package_lt9:
  pkg.installed: 
    - name: sles_es-release
    - refresh: True
{% endif %}

{% if grains['os_family'] == 'RedHat' and grains['osmajorrelease'] == 9 %}
install_package_9:
  pkg.installed: 
    - name: sll-release
    - refresh: True
{% endif %}
