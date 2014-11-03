#!/bin/bash

if [ $# -ne 2 ]
then
    echo "$0 <type> <workspace>"
    echo "type: either jenkins, dev or stage"
    echo "workspace: the directory where the app lies"
    echo "if type is dev we assume that you have already activated your venv"
    exit 1
fi

TYPE=$1
WORKSPACE=$2
REQ="requirements.txt"

if [ "$TYPE" != "jenkins" -a "$TYPE" != "stage" -a "$TYPE" != "dev" ]
then
    echo "Type must be either jenkins, dev or stage"
    exit 1
fi

if [ "$TYPE" = "jenkins" -o "$TYPE" = "dev" ]
then
    REQ="dev-requirements.txt"
fi

source ../env.sh
if [ "$TYPE" != "dev" ]
then
    source $WORKSPACE/../env/bin/activate
fi
cd $WORKSPACE

pip install -r $REQ
python devopsblog/manage.py syncdb --noinput
python devopsblog/manage.py migrate
python devopsblog/manage.py collectstatic --noinput

if [ "$TYPE" = "jenkins" ]
then
    python manage.py jenkins
fi

touch $WORKSPACE/reload-uwsgi
