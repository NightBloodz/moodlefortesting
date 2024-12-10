export MOODLE_DOCKER_DB=mysql # or mariadb, mysql, etc.
export MOODLE_DOCKER_PHP_VERSION=8.1 # or another supported version like 7.4


export MOODLE_DOCKER_PHP_DEBUG=1
export XDEBUG_CONFIG="remote_host=host.docker.internal idekey=VSCODE" # Adjust `idekey` for your IDE



# Change ./moodle to your /path/to/moodle if you already have it checked out
export MOODLE_DOCKER_WWWROOT="/home/nightbloodz/bugbounty/moodle/moodle-docker/moodleRepo"

# Ensure customized config.php for the Docker containers is in place
#cp config.docker-template.php $MOODLE_DOCKER_WWWROOT/config.php

# Start up containers
bin/moodle-docker-compose up -d 

# Install XDebug extension with PECL
bin/moodle-docker-compose exec webserver pecl install xdebug

# Set some wise setting for live debugging - change this as needed
conf=$(cat <<'EOF'
; Settings for Xdebug Docker configuration
xdebug.mode = debug
xdebug.client_host = host.docker.internal
xdebug.start_with_request = yes
; Some IDEs (eg PHPSTORM, VSCODE) may require configuring an IDE key, uncomment if needed
; xdebug.idekey=MY_FAV_IDE_KEY
EOF
)
bin/moodle-docker-compose exec webserver bash -c "echo '$conf' >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini"

# Enable XDebug extension in Apache and restart the webserver container
bin/moodle-docker-compose exec webserver docker-php-ext-enable xdebug
bin/moodle-docker-compose restart webserver

