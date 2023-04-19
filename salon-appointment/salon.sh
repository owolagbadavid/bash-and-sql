#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --no-align -t -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

echo -e "Welcome to My Salon, how can I help you?\n"

MAIN_MENU(){
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  echo "$($PSQL "SELECT * FROM SERVICES")" | while IFS="|" read SERVICE_ID SERVICE_NAME
  do
  echo "$SERVICE_ID) $SERVICE_NAME"
  done
  read SERVICE_ID_SELECTED
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    MAIN_MENU "Please enter a number"
  else
    SERVICE_NAME=$($PSQL "SELECT NAME FROM SERVICES WHERE SERVICE_ID=$SERVICE_ID_SELECTED")
    if [[ -z $SERVICE_NAME ]]
    then
      MAIN_MENU "I could not find that service. What would you like today?"
    else
      APPOINTMENT_MENU
    fi
  fi
}

REGISTER_CUSTOMER(){
 echo -e "\nWhat's your phone number?"
 read CUSTOMER_PHONE
 CUSTOMER_NAME=$($PSQL "SELECT NAME FROM CUSTOMERS WHERE PHONE='$CUSTOMER_PHONE'")
 if [[ -z $CUSTOMER_NAME ]]
 then
  echo -e "\nI don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME
  INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO CUSTOMERS(NAME, PHONE) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
  while [[ ! $INSERT_CUSTOMER_RESULT == 'INSERT 0 1' ]]
  do
    echo -e "\nThere was a problem adding this customer"
    REGISTER_CUSTOMER
  done
 fi
}
APPOINTMENT_MENU(){
 REGISTER_CUSTOMER 
 echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
 read SERVICE_TIME
#  while [[ ! $SERVICE_TIME =~ ^((1[0-2]|0?[1-9])(:[0-5][0-9])?(AM|PM|am|pm)?|(1[3-9]|2[0-3])(:[0-5][0-9])?)$ ]]
#  do
  # echo -e "\nPlease enter a valid time"
#   read SERVICE_TIME
#  done
 CUSTOMER_ID=$($PSQL "SELECT CUSTOMER_ID FROM CUSTOMERS WHERE PHONE='$CUSTOMER_PHONE'")
 INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO APPOINTMENTS(SERVICE_ID, CUSTOMER_ID, TIME) VALUES($SERVICE_ID_SELECTED, $CUSTOMER_ID, '$SERVICE_TIME')")
 if [[ $INSERT_APPOINTMENT_RESULT != "INSERT 0 1" ]]
 then
  echo -e "\nThere was a problem booking that appointment"
  APPOINTMENT_MENU 
 else
  echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
 fi

}


MAIN_MENU
