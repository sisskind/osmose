## Pre-reqs
sudo apt-get update
sudo apt-get upgrade -y

nodejs
sudo apt-get install -y gettext postgresql postgresql-contrib postgis python2.7 python2.7-dev virtualenv gcc pkg-config libpng-dev libjpeg-dev libfreetype6-dev postgresql-server-dev-all libgeos-dev g++ python-shapely nodejs-legacy npm python-dateutil python-imposm-parser python-lockfile python-polib python-poster python-psycopg2 python-shapely python-regex git python-dev python-virtualenv libpq-dev protobuf-compiler libprotobuf-dev apache2 apache2-dev

## Install Backend
# Clone repo
cd /usr/local
# sudo git clone https://github.com/osm-fr/osmose-backend
sudo chown -R ubuntu:ubuntu osmose-backend
cd osmose-backend

## Make data results directory
mkdir -p data/work/ubuntu
mkdir -p data/work/ubuntu/cache

## Setup Python Virtual-env
virtualenv --python=python2.7 osmose-backend-venv
source osmose-backend-venv/bin/activate
pip install -r requirements.txt
pip install -r requirements-dev.txt

## Install Database
sudo su - postgres
createuser osmose
# Set your own password
psql -c "ALTER ROLE osmose WITH PASSWORD '-osmose-';"
createdb -E UTF8 -T template0 -O osmose osmose
# Enable extensions
psql -c "CREATE extension hstore; CREATE extension fuzzystrmatch; CREATE extension unaccent; CREATE extension postgis;" osmose
psql -c "GRANT SELECT,UPDATE,DELETE ON TABLE spatial_ref_sys TO osmose;" osmose
psql -c "GRANT SELECT,UPDATE,DELETE,INSERT ON TABLE geometry_columns TO osmose;" osmose
exit

# Install Java 8
sudo apt install openjdk-8-jre-headless  # requires 'Y'

## Configure Backend
# Configure the url_frontend_update in modules/config.py to url to where your frontend will live
# Configure database connection strings in osmose_config.py
db_base = osmose # database name
db_user = osmose # database user
db_password = # database password if needed
db_host = # database hostname if needed

# Configure osmose frontend password
# vim osmose_config_password.py
# def set_password(config):
#   for country in config.keys():
#     for k in config[country].analyser.keys():
#       config[country].analyser[k] = 'foo'

## Test backend
./osmose_run.py -h

## Install Frontend
# Clone repo
cd /usr/local/
#sudo git clone https://github.com/osm-fr/osmose-frontend
sudo chown -R ubuntu:ubuntu osmose-frontend
cd osmose-frontend/

# Create Frontend Virtual-env
virtualenv --python=python2.7 osmose-frontend-venv
source osmose-frontend-venv/bin/activate
pip install -r requirements.txt

# Generate Translation Files
cd po && make mo

## Create frontend database
sudo su - postgres
# Set your own password
createdb -E UTF8 -T template0 -O osmose osmose_frontend
# Enable extensions
psql -c "CREATE extension hstore" osmose_frontend

## Edit Frontend Schema
# Edit tools/database/schema.sql

# Change source table id value from INTEGER to SERIAL
# Put this at the bottom of the file

# --
# -- Name: grant privs to marker and source id sequences
# --
# GRANT ALL ON sequence marker_id_seq TO osmose;
# GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO osmose;
# grant all on sequence source_password_source_id_seq to osmose;
# grant all on sequence source_id_seq to osmose;

## Migrate Schema
sudo su - postgres
psql osmose_frontend -f /usr/local/osmose-frontend/tools/database/schema.sql

# Generate Markers
cd ../tools && ./make-markers.py

# Install Javascript libraries
npm install
npm run build

## Setup single country with all Analyzers from backend
# Run usa_hawaii.sql file to import country analyzers (usa_hawaii is the example - you can change the country name for whichever you want to import)

sudo su - postgres
psql osmose_frontend -f /usr/local/osmose-frontend/usa_hawaii.sql

# Import Country data to osmose-frontend
cd /usr/local/osmose-backend
./osmose_run.py --country=usa_hawaii
