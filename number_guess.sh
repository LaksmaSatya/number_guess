#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo -e "\nWelcome to number guessing game\n"

echo Enter your username:
read USERNAME

#username selection
USERNAME_SELECTION=$($PSQL "SELECT username FROM users WHERE username='$USERNAME'")

#If username doesn't exist
if [[ -z $USERNAME_SELECTION ]]
then
  
  echo -e "\nWelcome, $(echo $USERNAME | sed -E 's/^ *| *$//g')! It looks like this is your first time here."
else 
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username='$USERNAME'")
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username='$USERNAME'")
  echo -e "\nWelcome back, $USERNAME_SELECTION! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

#randomize the number between 1 to 1000
SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))
GUESS=0
echo -e "\nGuess the secret number between 1 and 1000:"

GUESS_NUMBER() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  read NUMBER
  GUESS=$(( $GUESS + 1 ))

  #if the number wasn't integer
  if [[ ! $NUMBER =~ ^[0-9]+$ ]]
  then 
    GUESS_NUMBER "That is not an integer, guess again:"
  else 
    if [[ $NUMBER -gt $SECRET_NUMBER ]]
    then
      GUESS_NUMBER "It's lower than that, guess again:"
    elif [[ $NUMBER -lt $SECRET_NUMBER ]]
    then
      GUESS_NUMBER "It's higher than that, guess again:"
    else 
      echo -e "\nYou guessed it in $GUESS tries. The secret number was $SECRET_NUMBER. Nice job!"
    fi
  fi
}

GUESS_NUMBER
#input data to database
if [[ -z $USERNAME_SELECTION ]]
then
  INSERT_NEW_DATA=$($PSQL "INSERT INTO users(username,games_played,best_game) VALUES('$USERNAME',1,$GUESS)")
else
  GAMES_PLAYED_UPDATE=$(( $GAMES_PLAYED + 1 ))
  if [[ $GUESS -lt $BEST_GAME ]]
  then
    UPDATE_DATA=$($PSQL "UPDATE users SET best_game=$GUESS,games_played=$GAMES_PLAYED_UPDATE WHERE username='$USERNAME'")
  else
    UPDATE_DATA=$($PSQL "UPDATE users SET games_played=$GAMES_PLAYED_UPDATE WHERE username='$USERNAME'")
  fi
fi
