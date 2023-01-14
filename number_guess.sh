#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

TARGET=(( $RANDOM % 1000 + 1 ))

echo "Enter your username:"
read USERNAME

CHECK_NAME_RESULT=$($PSQL "SELECT * FROM users WHERE username='$USERNAME';")
if [[ -z $CHECK_NAME_RESULT ]]
then
  #New person, say new person text and insert new row
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  INSERT_NEW_USER_RESULT=$($PSQL "INSERT INTO users(username, games_played, best_game) VALUES('$USERNAME', 0, 999);")
else
  #Existing person, get their info and say existing person text
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username='$USERNAME';")
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username='$USERNAME';")
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi