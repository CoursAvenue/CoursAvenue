rake import:clean
rake db:seed
rake "import:structures[Export/Structure.csv]"
rake "import:renting_rooms[Export/Location.csv]"
rake "import:courses_prices_and_plannings[Export/Planning-Cours.csv]"
