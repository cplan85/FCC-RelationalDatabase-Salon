#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"


echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
 # Get all services from db
  SERVICES_OFFERED=$($PSQL "SELECT * FROM services")
  # Take result of services offered, loop through them and echo them
  echo -e "$SERVICES_OFFERED" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done 



  read SERVICE_ID_SELECTED
  SERVICE_ID_SELECTED_LOOKUP=$($PSQL "SELECT service_id FROM services WHERE service_id="$SERVICE_ID_SELECTED"")



            # if not available
  if [[ -z $SERVICE_ID_SELECTED_LOOKUP ]]
      then
        # send to main menu
        MAIN_MENU "I could not find that service. What would you like today?"
      
  
      else
        # get customer info
        echo -e "\nWhat's your phone number?"
        read CUSTOMER_PHONE
        
        CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

        

          # if customer doesn't exist
          if [[ -z $CUSTOMER_NAME ]]
          then
            # get new customer name
            echo -e "\nI don't have a record for that phone number, what's your name?"
            read CUSTOMER_NAME

            # insert new customer
            INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')") 
          fi
      
       

        echo -e "\nWhat time would you like your cut, $CUSTOMER_NAME?"
        read SERVICE_TIME


          # get customer_id
         CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

          # insert into appointments
        INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES('$CUSTOMER_ID', $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

        SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id="$SERVICE_ID_SELECTED"")

        echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
        EXIT
  fi
         
}

EXIT() {
  echo -e "\nThank you for stopping in.\n"
}

MAIN_MENU