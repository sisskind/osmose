## Pre-reqs
sudo apt-get update
sudo apt-get upgrade -y

curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.0/install.sh | bash
source ~/.bashrc
nvm install 9
sudo apt-get install -y gettext postgresql postgresql-contrib postgis python2.7 python2.7-dev virtualenv gcc pkg-config libpng-dev libjpeg-dev libfreetype6-dev postgresql-server-dev-all libgeos-dev g++ python-shapely python-dateutil python-imposm-parser python-lockfile python-polib python-poster python-psycopg2 python-shapely python-regex git python-dev python-virtualenv libpq-dev protobuf-compiler libprotobuf-dev apache2 apache2-dev

## Install Backend
# Clone repo
cd /usr/local
cd osmose-backend

## Make data extracts directory
mkdir -p data/work/vagrant/extracts

## Setup Python Virtual-env
virtualenv --python=python2.7 osmose-backend-venv
source osmose-backend-venv/bin/activate
pip install -r requirements.txt
pip install -r requirements-dev.txt
deactivate

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
sudo apt-get install -y openjdk-8-jre-headless

## Configure Backend
# Configure database connection strings in osmose_config.py
db_base = osmose # database name
db_user = osmose # database user
db_password = None # database password if needed
db_host = None # database hostname if needed

# Set all options to trust in pg_hba.conf

## Update dir_work in modules/config.py
dir_work = "/usr/local/osmose-backend/data/work/%s" % (username)

## Test backend
./osmose_run.py -h

