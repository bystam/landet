git subtree push --prefix api/ heroku master

if [ "$1" = "resetdb" ]
then
  heroku pg:reset DATABASE_URL --confirm landet
fi
