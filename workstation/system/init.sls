{% from "workstation/map.jinja" import workstation with context %}

#####################################################################
## Remove message of the day after bootstrap
#####################################################################

/etc/motd:
  file.absent

#####################################################################
## GPG
#####################################################################

gnupg: pkg.installed

838460D0CBD26750AB26DF8FB9FB68F98F88BA47:
  gpg.present:
    - user: {{ workstation.username }}
    - keyserver: pgp.mit.edu
    - trust: ultimately

/home/{{ workstation.username }}/.gnupg:
  file.directory:
    - user: {{ workstation.username }}
    - group: {{ workstation.username }}
    - recurse:
      - user
      - group

#####################################################################
## Scripts and dotfiles
#####################################################################

salt://workstation/system/templates/binfiles-init.sh:
  cmd.script:
    - cwd: /home/{{ workstation.username }}
    - runas: {{ workstation.username }}
    - creates: /home/{{ workstation.username }}/bin

salt://workstation/system/templates/dotfiles-init.sh:
  cmd.script:
    - cwd: /home/{{ workstation.username }}
    - runas: {{ workstation.username }}
    - creates: /home/{{ workstation.username }}/.dotfiles

#####################################################################
## Sync time
#####################################################################

ntp:
  pkg.installed: []
  service.running:
    - name: ntpd
    - enable: True
    - require:
      - pkg: ntp

#####################################################################
## Yubikey
#####################################################################

yubikey-gpg-deps:
  pkg.installed:
    - pkgs:
      - libusb-compat
      - ccid

pcscd:
  service.running:
    - enable: true
    - require:
      - pkg: yubikey-gpg-deps

pcscd.socket:
  service.running:
    - enable: true
    - require:
      - pkg: yubikey-gpg-deps

/etc/udev/rules.d/70-u2f.rules:
  file.managed:
    - source: salt://workstation/system/templates/70-u2f.rules
    - user: root
    - group: root
    - mode: 644

#####################################################################
## Python and pip
#####################################################################

python-pip:
  pkg.installed

python2-pip:
  pkg.installed

#####################################################################
## Password Store
#####################################################################

pass:
  pkg.installed

xdotool:
  pkg.installed

#####################################################################
## Wireless
#####################################################################

/etc/netctl/interfaces/{{ workstation.wireless_interface }}:
  file.managed:
    - user: root
    - group: root
    - mode: 700
    - contents:
      - "ExecUpPost='/usr/local/sbin/netctl-exec.sh wireless up $Profile || true'"
      - "ExecDownPre='/usr/local/sbin/netctl-exec.sh wireless down $Profile || true'"

/usr/local/sbin/netctl-exec.sh:
  file.managed:
    - source: salt://workstation/system/templates/netctl-exec.sh
    - template: jinja
    - user: root
    - group: root
    - mode: 700

