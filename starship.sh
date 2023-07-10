# Load the zsh/parameter module
zmodload zsh/parameter

# Function to get the current time in milliseconds
__starship_get_time() {
  zmodload zsh/datetime
  zmodload zsh/mathfunc
  (( STARSHIP_CAPTURED_TIME = int(rint(EPOCHREALTIME * 1000)) ))
}

# Function to be executed before each new command line
prompt_starship_precmd() {
  # Save the command status and pipe status
  STARSHIP_CMD_STATUS=$?
  STARSHIP_PIPE_STATUS=(${pipestatus[@]})

  # Compute command duration if start time is available
  if (( ${+STARSHIP_START_TIME} )); then
    __starship_get_time
    (( STARSHIP_DURATION = STARSHIP_CAPTURED_TIME - STARSHIP_START_TIME ))
    unset STARSHIP_START_TIME
  else
    unset STARSHIP_DURATION
  fi

  # Count the number of jobs
  STARSHIP_JOBS_COUNT=${#jobstates}
}

# Function to be executed after the user submits the command line, but before it is executed
prompt_starship_preexec() {
  __starship_get_time
  STARSHIP_START_TIME=$STARSHIP_CAPTURED_TIME
}

# Add hook functions
autoload -Uz add-zsh-hook
add-zsh-hook precmd prompt_starship_precmd
add-zsh-hook preexec prompt_starship_preexec

# Set up a function to redraw the prompt when the user switches vi modes
starship_zle-keymap-select() {
  zle reset-prompt
}

# Check for an existing keymap-select widget
__starship_preserved_zle_keymap_select=${widgets[zle-keymap-select]#user:}
if [[ -z $__starship_preserved_zle_keymap_select ]]; then
  zle -N zle-keymap-select starship_zle-keymap-select
else
  # Define a wrapper function to call the original widget function and then the Starship's function
  starship_zle-keymap-select-wrapped() {
    $__starship_preserved_zle_keymap_select "$@"
    starship_zle-keymap-select "$@"
  }
  zle -N zle-keymap-select starship_zle-keymap-select-wrapped
fi

__starship_get_time
STARSHIP_START_TIME=$STARSHIP_CAPTURED_TIME

# Set environment variables
export STARSHIP_SHELL="zsh"
export VIRTUAL_ENV_DISABLE_PROMPT=1

# Enable prompt substitution
setopt promptsubst

# Set the prompt variables
PROMPT='$(starship prompt --terminal-width="$COLUMNS" --keymap="${KEYMAP:-}" --status="$STARSHIP_CMD_STATUS" --pipestatus="${STARSHIP_PIPE_STATUS[*]}" --cmd-duration="${STARSHIP_DURATION:-}" --jobs="$STARSHIP_JOBS_COUNT")'
RPROMPT='$(starship prompt --right --terminal-width="$COLUMNS" --keymap="${KEYMAP:-}" --status="$STARSHIP_CMD_STATUS" --pipestatus="${STARSHIP_PIPE_STATUS[*]}" --cmd-duration="${STARSHIP_DURATION:-}" --jobs="$STARSHIP_JOBS_COUNT")'
PROMPT2='$(starship prompt --continuation)'
