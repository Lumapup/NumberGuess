#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

TARGET=$(($RANDOM % 1000 + 1))

echo $TARGET

echo "Enter your username:"
read USERNAME

CHECK_NAME_RESULT=$($PSQL "SELECT * FROM users WHERE username='$USERNAME';")
if [[ -z $CHECK_NAME_RESULT ]]
then
  #New person, say new person text and insert new row
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  GAMES_PLAYED=0
  BEST_GAME=999
  INSERT_NEW_USER_RESULT=$($PSQL "INSERT INTO users(username, games_played, best_game) VALUES('$USERNAME', $GAMES_PLAYED, $BEST_GAME);")
else
  #Existing person, get their info and say existing person text
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username='$USERNAME';")
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username='$USERNAME';")
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

echo "Guess the secret number between 1 and 1000:"
read GUESS

GUESS_COUNT=1

until [[ $GUESS -eq $TARGET ]]
do
  #Only do main stuff if guess is an integer
  if [[ $GUESS =~ ^[0-9]+$ ]]
  then
    #Give hint, increment guess count, get new guess
    if [[ $GUESS -gt $TARGET ]]
    then
      echo "It's lower than that, guess again:"
    else
      echo "It's higher than that, guess again:"
    fi
    ((GUESS_COUNT=GUESS_COUNT + 1))
    read GUESS
  else
    #Ask for integer
    echo "That is not an integer, guess again:"
    read GUESS
  fi
done

#Say final message and update games played and high score
echo "You guessed it in $GUESS_COUNT tries. The secret number was $TARGET. Nice job!"
((GAMES_PLAYED++))
GAME_NUM_UPDATE_RESULT=$($PSQL "UPDATE users SET games_played=$GAMES_PLAYED WHERE username='$USERNAME';")
#If best game, update best_game
if [[ $GUESS_COUNT -lt $BEST_GAME ]]
then
  BEST_GAME_UPDATE_RESULT=$($PSQL "UPDATE users SET best_game=$GUESS_COUNT WHERE username='$USERNAME';")
fi