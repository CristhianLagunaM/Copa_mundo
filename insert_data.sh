#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# Vaciar las tablas y reiniciar los IDs
echo "$($PSQL "TRUNCATE TABLE games, teams RESTART IDENTITY;")"

# Leer el archivo games.csv y procesar cada línea
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  # Saltar la cabecera del CSV
  if [[ $YEAR != "year" ]]; then

    # Insertar el equipo ganador si no existe
    TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    if [[ -z $TEAM_ID ]]; then
      echo "$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")"
    fi

    # Insertar el equipo oponente si no existe
    TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    if [[ -z $TEAM_ID ]]; then
      echo "$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")"
    fi

    # Obtener los IDs de ambos equipos
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")

    # Insertar el partido en la tabla games
    echo "$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")"
  fi
done
