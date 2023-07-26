(( ${+commands[rtx]} )) && () {
  local command="${commands[rtx]}"

  # generating activation file
  local activatefile="$1/rtx-activate.zsh"
  if [[ ! -e "$activatefile" || "$activatefile" -ot "$command" ]]; then
    "$command" activate zsh >| "$activatefile"
    zcompile -UR "$activatefile"
  fi

  source "$activatefile"

  if (( $+functions[_rtx_hook] )); then
    function _self_destruct_rtx_hook {
        _rtx_hook
        # remove self from precmd
        precmd_functions=(${(@)precmd_functions:#_self_destruct_rtx_hook})
        builtin unfunction _self_destruct_rtx_hook
    }
    precmd_functions=( _self_destruct_rtx_hook ${(@)precmd_functions:#_rtx_hook} )
  fi

  # generating completions
  local compfile="$1/_rtx"
  if [[ ! -e "$compfile" || "$compfile" -ot "$command" ]]; then
    "$command" complete --shell zsh >| "$compfile"
  fi
} ${0:h}
