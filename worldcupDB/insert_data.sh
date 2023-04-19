#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo "$($PSQL "TRUNCATE TEAMS, GAMES")"
echo "$($PSQL "ALTER SEQUENCE games_game_id_seq RESTART WITH 1")"
echo "$($PSQL "ALTER SEQUENCE teams_team_id_seq RESTART WITH 1")"

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  #insert teams
  if [[ $YEAR != 'year' ]]
  then
    #get team_id

    #FOR OPPONENT
    OPPONENT_ID=$($PSQL "SELECT TEAM_ID FROM TEAMS WHERE NAME='$OPPONENT'")
    if [[ -z $OPPONENT_ID ]]
    then
      # insert team
      INSERT_TEAM_RESULT=$($PSQL "INSERT INTO TEAMS(NAME) VALUES('$OPPONENT')")
      if [[ $INSERT_TEAM_RESULT == 'INSERT 0 1' ]]
      then
      echo Inserted into TEAMS, $OPPONENT
      OPPONENT_ID=$($PSQL "SELECT TEAM_ID FROM TEAMS WHERE NAME='$OPPONENT'")
      fi
    fi

    #FOR WINNER
    WINNER_ID=$($PSQL "SELECT TEAM_ID FROM TEAMS WHERE NAME='$WINNER'")
    if [[ -z $WINNER_ID ]]
    then
      # insert team
      INSERT_TEAM_RESULT=$($PSQL "INSERT INTO TEAMS(NAME) VALUES('$WINNER')")
      if [[ $INSERT_TEAM_RESULT == 'INSERT 0 1' ]]
      then
      echo Inserted into TEAMS, $WINNER
      WINNER_ID=$($PSQL "SELECT TEAM_ID FROM TEAMS WHERE NAME='$WINNER'")
      fi  
    fi

    INSERT_GAME_RESULT=$($PSQL "INSERT INTO GAMES(YEAR, ROUND, WINNER_ID, OPPONENT_ID, WINNER_GOALS, OPPONENT_GOALS) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS ,$OPPONENT_GOALS)")
    if [[ $INSERT_GAME_RESULT == 'INSERT 0 1' ]]
    then
    echo INSERTED INTO GAMES, $YEAR, $ROUND, $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS ,$OPPONENT_GOALS
    fi
  else
    echo -e "\nStarted entering data into database\n"
  fi




done
