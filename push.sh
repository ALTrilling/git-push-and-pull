# usage: bash push.sh COMMIT_MESSAGE YOUR_PASSWORD YOUR_GITHUB_REPO_URL
if [ "$#" -ne 3 ]; then
    echo "illegal numbrer of params"
    exit 1
fi
PASSWORD=$2
REPO_URL=$3
git add .
git commit -m "$1"
git push -u origin main
# ssh into the server. The code below is run on the server
ssh adrian@147.182.215.66 << EOF
    # this allows for using sudo privaleges future times in the session. There is almost definetly a better way to do this
    echo $PASSWORD | sudo -S echo

    cd /var/www

    # removes the current webapp folder if this exists
    sudo rm -r webapp
    sudo git clone $REPO_URL webapp
    cd webapp

    # sets up the venv
    sudo python3 -m venv venv
    sudo chown -R adrian:adrian /var/www/webapp/venv
    source venv/bin/activate

    # installs packages
    pip install wheel gunicorn flask
    # install other packages as well
    pip install pytz

    # restart flask
    sudo systemctl restart flask
EOF