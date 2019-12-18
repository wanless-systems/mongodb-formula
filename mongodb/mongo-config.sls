{% from "mongodb/map.jinja" import host_lookup as config with context %}

# Create mongodb config file using template
/etc/mongod.conf:
  file.managed:
    - source: salt://mongodb/files/mongod.conf
    - template: jinja
    - user: root
    - group: root
    - mode: '0644'

# Create mongodb folder if not exists
{{ config.mongodb.process_pidfilepath }}:
  file.directory:
    - owner: {{ config.package.mongo_user }}
    - group: {{ config.package.mongo_group }}
    - mode: 0775

# Add config to allow systemd to auto create mongodb folder
/usr/lib/tmpfiles.d/mongodb.conf:
  file.managed:
    - contents: |
        d    {{ config.mongodb.process_pidfilepath }}   0755 {{ config.package.mongo_user }} {{ config.package.mongo_group }} - -
    - user: root
    - group: root
    - mode: '0644'

# Setup replica set keyfile if replication == true
{% if config.mongodb.use_keyfile %}

{{ config.mongodb.security_keyfile }}:
  file.managed:
    - contents_pillar: mongodb:lookup:mongodb:keyfile_contents
    - owner: {{ config.package.mongo_user }}
    - group: {{ config.package.mongo_group }}
    - mode: 0600
    {% if config.mongodb.restart_service_after_state_change == true %}
    - watch_in:
      - service: service-mongod
    {% endif %}

{% endif %}
