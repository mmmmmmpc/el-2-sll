/tmp/testing-salt:
  file.touch

/usr/share/redhat-release:
  file.absent
  
/etc/dnf/protected.d/redhat-release.conf:
  file.absent