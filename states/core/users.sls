root:
  user.present:
    - password: {{ pillar['users']['root']['password'] }}

atmoz:
  user.present:
    - password: {{ pillar['users']['atmoz']['password'] }}
    - gid: atmoz
    - groups:
      - wheel
      - uucp

