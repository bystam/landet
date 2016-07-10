git push heroku `git subtree split --prefix api/ master`:master --force

if [ "$1" = "resetdb" ]
then
  heroku pg:reset DATABASE_URL --confirm landet
fi
