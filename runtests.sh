#!/usr/bin/bash -ex

gc() {
  retval=$?
  docker-compose -f docker-compose.yml down -v || :
  exit $retval
}
trap gc EXIT SIGINT

# Enter local-setup/ directory
# Run local instances for: dynamodb, gremlin-websocket, gremlin-http
function start_gemini_service {
    #pushd local-setup/
    echo "Invoke Docker Compose services"
    docker-compose -f docker-compose.yml up  --force-recreate -d
    #popd
}

start_gemini_service

export PYTHONPATH=`pwd`/src
echo "Create Virtualenv for Python deps ..."
function prepare_venv() {
    VIRTUALENV=`which virtualenv`
    if [ $? -eq 1 ]; then   
        # python34 which is in CentOS does not have virtualenv binary
        VIRTUALENV=`which virtualenv-3`
    fi
    ${VIRTUALENV} -p python3 venv && source venv/bin/activate
}
prepare_venv
pip3 install -r requirements.txt

py.test -s tests/

rm -rf venv/
