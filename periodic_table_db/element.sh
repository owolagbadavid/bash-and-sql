#!/bin/bash
PSQL="psql --username=freecodecamp -X --dbname=periodic_table -t --no-align -c"
function MAIN_MENU {
  if [[ ! $1 ]]
  then
    echo Please provide an element as an argument. 
  else
    #if argument is a number then it must be the atomic number
    if [[ $1 =~ ^[0-9]+$ ]]
    then
      ELEMENT=$($PSQL "SELECT * FROM ELEMENTS INNER JOIN PROPERTIES USING(ATOMIC_NUMBER) INNER JOIN TYPES USING(TYPE_ID) WHERE ATOMIC_NUMBER=$1 LIMIT 1") 
    #else it is element name or symbol
    else
      ELEMENT=$($PSQL "SELECT * FROM ELEMENTS INNER JOIN PROPERTIES USING(ATOMIC_NUMBER) INNER JOIN TYPES USING(TYPE_ID) WHERE SYMBOL='$1' OR NAME='$1' LIMIT 1") 
    fi
    #if element exists
    if [[ $ELEMENT ]]
    then
      #separate the fields with '|' and read the the values
      echo $ELEMENT | while IFS='|' read TYPE_ID ATOMIC_NUMBER SYMBOL NAME MASS MELTING BOILING TYPE
      do
      echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING celsius and a boiling point of $BOILING celsius."
      done
    else
      echo "I could not find that element in the database."
    fi
  fi

}

MAIN_MENU $1