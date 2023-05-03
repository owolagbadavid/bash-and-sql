#!/bin/bash
PSQL="psql --username=freecodecamp -X --dbname=number_guess -t --no-align -c"

echo -e "\n~~ Number Guessing Game ~~\n"
echo Enter your username:
read USERNAME


NUMBER=$(( RANDOM % 1000 + 1 ))
# echo $NUMBER

USER=$($PSQL "SELECT times_played, best_game FROM USERS WHERE USERNAME='$USERNAME'")
if [[ $USER ]]
then
  while IFS='|' read TIMES_PLAYED BEST_GAME
  do
    echo "Welcome back, $USERNAME! You have played $TIMES_PLAYED games, and your best game took $BEST_GAME guesses."
  done < <(echo $USER)
else
  INSERT_USER_RESULT=$($PSQL "INSERT INTO USERS(USERNAME) VALUES('$USERNAME')")
  USER=$($PSQL "SELECT times_played, best_game FROM USERS WHERE USERNAME='$USERNAME'")
  if [[ $INSERT_USER_RESULT == 'INSERT 0 1' ]]
  then
    echo "Welcome, $USERNAME! It looks like this is your first time here."
  else
    echo "error adding you to the database"
  fi
fi


echo -e "\nGuess the secret number between 1 and 1000:"
read USER_GUESS
NO_OF_GUESSES=1



while [[ $USER_GUESS != $NUMBER ]]
do
  if [[ ! $USER_GUESS =~ ^[0-9]+$ ]]
  then
    echo -e "\nThat is not an integer, guess again:"
    read USER_GUESS
    (( NO_OF_GUESSES++ ))
  elif [[ $USER_GUESS -lt $NUMBER ]]
  then
    echo -e "\nIt's higher than that, guess again:"
    read USER_GUESS
    (( NO_OF_GUESSES++ ))
  else
    echo -e "\nIt's lower than that, guess again:"
    read USER_GUESS
    (( NO_OF_GUESSES++ ))
  fi
done



echo $USER | while IFS="|"  read TIMES_PLAYED BEST_GAME
do
  if [[ $BEST_GAME ]]
  then
    if [[ $NO_OF_GUESSES -lt $BEST_GAME ]]
    then
      BEST_GAME=$NO_OF_GUESSES
    fi
  else
    BEST_GAME=$NO_OF_GUESSES
  fi
    (( TIMES_PLAYED++ ))
  UPDATE_USER_RESULT=$($PSQL "UPDATE USERS SET BEST_GAME=$BEST_GAME, TIMES_PLAYED=$TIMES_PLAYED WHERE USERNAME='$USERNAME'")
  if [[ $UPDATE_USER_RESULT == 'UPDATE 1' ]] 
  then
    echo -e "\nYou guessed it in $NO_OF_GUESSES tries. The secret number was $NUMBER. Nice job!"
  else
    echo -e "\nError updating your records"
  fi
done