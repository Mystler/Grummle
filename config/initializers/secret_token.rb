secrets = YAML.load_file('config/secrets.yml')
Grummle::Application.config.secret_key_base = secrets['secret_key_base']
