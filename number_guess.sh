#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=number_guess -t -c"
SECRET_NUMBER=$(($RANDOM % 1000 + 1))
USER_TRIES=0
# function to ask number
GUESS_NUMBER(){
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  
  read USER_NUMBER
  USER_TRIES=$(($USER_TRIES+1))

  #if input is not a number
  if [[ ! $USER_NUMBER =~ ^[0-9]+$ ]]
  then
    GUESS_NUMBER "That is not an integer, guess again:"
  fi

  # compare numbers
  if [[ $USER_NUMBER -eq $SECRET_NUMBER ]]
  then
    # save info game user
    INSERT_INFO_GAME=$($PSQL "INSERT INTO games(username_id, tries) VALUES($USERNAME_ID, $USER_TRIES)")

    echo -e "\nYou guessed it in $USER_TRIES tries. The secret number was $SECRET_NUMBER. Nice job!"
  else
    if [[ $USER_NUMBER -lt $SECRET_NUMBER ]]
    then
      GUESS_NUMBER "It's higher than that, guess again:"
    else
      GUESS_NUMBER "It's lower than that, guess again:" 
    fi
  fi
}

# ask username
echo -e "\nEnter your username:"
read USERNAME

# get username_id
USERNAME_ID=$($PSQL "SELECT username_id FROM usernames WHERE name='$USERNAME'")

# if not found
if [[ -z $USERNAME_ID ]]
then
  # save user
  SAVE_USERNAME=$($PSQL "INSERT INTO usernames(name) VALUES('$USERNAME')")

  # get new username_id
  USERNAME_ID=$($PSQL "SELECT username_id FROM usernames WHERE name='$USERNAME'")

  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
else
  # get games played
  GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games WHERE username_id = $USERNAME_ID")
  GAMES_PLAYED_FORMATTED=$(echo $GAMES_PLAYED | sed -r 's/^ *| *$//g')

  # get best game
  BEST_GAME=$($PSQL "SELECT MIN(tries) FROM games WHERE username_id = $USERNAME_ID")
  BEST_GAME_FORMATTED=$(echo $BEST_GAME | sed -r 's/^ *| *$//g')

  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED_FORMATTED games, and your best game took $BEST_GAME_FORMATTED guesses."
fi

GUESS_NUMBER "Guess the secret number between 1 and 1000:"
