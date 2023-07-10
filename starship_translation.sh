#!/bin/bash

# Define __starship_get_time function
if [[ $BASH_VERSION =~ ^[1-4] ]]; then
  __starship_get_time() {
    STARSHIP_CAPTURED_TIME=$(starship time)
  }
else
  __starship_get_time() {
    STARSHIP_CAPTURED_TIME=$(date +%s%3N)
  }
fi

# Define prompt_starship_precmd function
prompt_starship_precmd() {
  STARSHIP_CMD_STATUS=$?
  STARSHIP_PIPE_STATUS=("${PIPESTATUS[@]}")

  if [[ -n "$STARSHIP_START_TIME" ]]; then
    __starship_get_time
    (( STARSHIP_DURATION = STARSHIP_CAPTURED_TIME - STARSHIP_START_TIME ))
    unset STARSHIP_START_TIME
  else
    unset STARSHIP_DURATION
  fi

  STARSHIP_JOBS_COUNT=${#jobstates[@]}
}

# Define prompt_starship_preexec function
prompt_starship_preexec() {
  __starship_get_time
  STARSHIP_START_TIME=$STARSHIP_CAPTURED_TIME
}

# Add hooks
trap prompt_starship_precmd DEBUG
PROMPT_COMMAND=prompt_starship_preexec

# Set up the session key that will be used to store logs
STARSHIP_SESSION_KEY="$RANDOM$RANDOM$RANDOM$RANDOM$RANDOM"
STARSHIP_SESSION_KEY="${STARSHIP_SESSION_KEY}0000000000000000"
export STARSHIP_SESSION_KEY=${STARSHIP_SESSION_KEY:0:16}

# Disable virtual environment prompt
export VIRTUAL_ENV_DISABLE_PROMPT=1

# Enable prompt substitution
shopt -s promptvars

# Define the prompt variables
PROMPT='$(starship prompt --terminal-width="$COLUMNS" --keymap="${KEYMAP:-}" --status="$STARSHIP_CMD_STATUS" --pipestatus="${STARSHIP_PIPE_STATUS[*]}" --cmd-duration="${STARSHIP_DURATION:-}" --jobs="$STARSHIP_JOBS_COUNT")'
RPROMPT='$(starship prompt --right --terminal-width="$COLUMNS" --keymap="${KEYMAP:-}" --status="$STARSHIP_CMD_STATUS" --pipestatus="${STARSHIP_PIPE_STATUS[*]}" --cmd-duration="${STARSHIP_DURATION:-}" --jobs="$STARSHIP_JOBS_COUNT")'
PROMPT2='$(starship prompt --continuation)'

# Run the Bash shell
bash
