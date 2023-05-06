#!/bin/bash
PSQL="psql  --username=freecodecamp --dbname=number_guess -t --no-align -c"
echo "Enter your username:"
read USERNAME
GET_USERNAME=$($PSQL "SELECT user_id FROM game WHERE username='$USERNAME'")
if [[ ! -z $GET_USERNAME ]]
then
  GET_GAMES_PLAYED=$($PSQL "SELECT games_played FROM game WHERE username='$USERNAME'")
  GET_BEST_GAME=$($PSQL "SELECT best_game FROM game WHERE username='$USERNAME'")
  echo "Welcome back, $USERNAME! You have played $GET_GAMES_PLAYED games, and your best game took $GET_BEST_GAME guesses."
else
  INSERT_NAME=$($PSQL "INSERT INTO game(username) VALUES ('$USERNAME')")
  echo "Welcome, $USERNAME! It looks like this is your first time here."
fi
RANDOM_NUMBER=$($PSQL "SELECT floor(random() * 1000 + 1)::int;")
NUMBER_OF_GUESS=0
echo "Guess the secret number between 1 and 1000:"
read GUESS
while [[ $GUESS != $RANDOM_NUMBER ]];
do 
  if [[ ! $GUESS =~ ^[0-9]+$ ]];
  then
    echo "That is not an integer, guess again:"
    read GUESS
  elif [[ $GUESS < $RANDOM_NUMBER ]]
  then
    NUMBER_OF_GUESS=$(($NUMBER_OF_GUESS+1))
    echo "It's higher than that, guess again:"
    read GUESS
  elif [[ $GUESS > $RANDOM_NUMBER ]]
  then
    NUMBER_OF_GUESS=$(($NUMBER_OF_GUESS+1))
    echo "It's lower than that, guess again:"
    read GUESS
  fi
done
NUMBER_OF_GUESS=$(($NUMBER_OF_GUESS+1))
GET_GAMES_PLAYED=$($PSQL "SELECT games_played FROM game WHERE username='$USERNAME'")
if [[ -z $GET_GAMES_PLAYED ]]
then
  UPDATE_GAMES_PLAYED=$($PSQL "UPDATE game SET games_played = 1 WHERE username = '$USERNAME';")
else
  UPDATE_GAMES_PLAYED=$($PSQL "UPDATE game SET games_played = games_played + 1 WHERE username = '$USERNAME';")
fi

GET_BEST_GAME=$($PSQL "SELECT best_game FROM game WHERE username='$USERNAME'")
if [[ -z $GET_BEST_GAMES ]]
then
  UPDATE_BEST_GAME=$($PSQL "UPDATE game SET best_game = $NUMBER_OF_GUESS WHERE username = '$USERNAME';")
elif [[ $NUMBER_OF_GUESS < $GET_BEST_GAME ]]
then
  UPDATE_BEST_GAME=$($PSQL "UPDATE game SET best_game = $NUMBER_OF_GUESS WHERE username = '$USERNAME';")
fi
echo "You guessed it in $NUMBER_OF_GUESS tries. The secret number was $RANDOM_NUMBER. Nice job!"