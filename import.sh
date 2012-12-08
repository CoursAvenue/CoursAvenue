rake import:clean
rake "import:structures[Export/Structure.csv]"
rake "import:renting_rooms[Export/Location.csv]"
rake "import:courses_prices_and_plannings[Export/Planning-Cours.csv]"

# heroku pg:reset DATABASE
# heroku run rake import:clean
# heroku run rake "import:structures[Export/Structure.csv]"
# heroku run rake "import:renting_rooms[Export/Location.csv]"
# heroku run rake "import:courses_prices_and_plannings[Export/Planning-Cours.csv]"
