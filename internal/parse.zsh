function _p9k_skip_until() {
  [[ -z $1 ]] && return
  while _p9k_next_token 0; do
    [[ $token == $~1 ]] && return
  done
}

function _p9k_next_token() {
  if (( $#tokens == aln[-1] )); then
    aln[-1]=()
    alp[-1]=()
  fi

  if (( $#tokens == alf[-1] )); then
    alf[-1]=()
    1=1
  fi

  while (( $#tokens )); do
    token=$tokens[1]
    shift 1 tokens

    if (( $+galiases[$token] )); then
      (( aln[(eI)p$token] )) && return
      local n=p$token s=$galiases[$token]
    elif (( ! $1 )); then
      return
    elif (( $+aliases[$token] )); then
      (( aln[(eI)p$token] )) && return
      local n=p$token s=$aliases[$token]
    elif [[ $token == (#b)?*.(?*) ]] && (( $+saliases[$match[1]] )); then
      (( aln[(eI)s$match[1]] )) && return
      local n=s$match[1] s=${saliases[$match[1]]%% #}
    else
      return 0
    fi

    aln+=$n
    alp+=$#tokens
    [[ $s == *' ' ]] && alf+=$#tokens

    [[ -o interactive_comments ]] && tokens[1,0]=(${(Z+C+)s}) || tokens[1,0]=(${(z)s})
  done

  token=
  return 1
}

typeset -gA _p9k_skip_token=(
  '}' ''
  '|' ''
  '||' ''
  '&' ''
  '&&' ''
  '|&' ''
  '&!' ''
  '&|' ''
  ')' ''
  '(' ''
  '{' ''
  '()' ''
  '!' ''
  ';' ''
  'if' ''
  'fi' ''
  'elif' ''
  'then' ''
  'while' ''
  'until' ''
  'do' ''
  'coproc' ''
  'nocorrect' ''
  'time' ''
  '-' ''
  'builtin' ''
  '[[' '\]\]'
  '((' '\)\)'
  'case' '\)|esac'
  ';;' '\)|esac'
  ';&' '\)|esac'
  ';|' '\)|esac'
  '&>' '*'
  '>' '*'
  '>&' '*'
  '<' '*'
  '<&' '*'
  '<>' '*'
  '&>|' '*'
  '>|' '*'
  '&>>' '*'
  '>>' '*'
  '>>&' '*'
  '&>>|' '*'
  '>>|' '*'
)

typeset -gA _p9k_redirect=(
  '&>' ''
  '>' ''
  '>&' ''
  '<' ''
  '<&' ''
  '<>' ''
  '&>|' ''
  '>|' ''
  '&>>' ''
  '>>' ''
  '>>&' ''
  '&>>|' ''
  '>>|' ''
)

function _p9k_extract_commands() {
  local rcquotes
  [[ -o rcquotes ]] && rcquotes=(-o rcquotes)

  emulate -L zsh -o extended_glob -o no_nomatch $rcquotes

  typeset -ga _p9k_commands=()
  local -a aln alp alf match mbegin mend
  [[ -o interactive_comments ]] && local tokens=(${(Z+C+)1}) || local tokens=(${(z)1})

  while _p9k_next_token 1; do
    local r=${token#<0-255>}
    if (( $+_p9k_skip_token[$r] )); then
      if (( $+_p9k_skip_token[$token] )); then
        _p9k_skip_until $_p9k_skip_token[$token]
        continue
      fi
      if (( $+_p9k_redirect[$r] )); then
        _p9k_next_token 0
        continue
      fi
    fi

    if [[ $token == *=* ]]; then
      local v=${(S)token/#(<->|([[:alpha:]_][[:IDENT:]]#(|'['*[^\\](\\\\)#']')))(|'+')=}
      if (( $#v < $#token )); then
        [[ $v == '(' ]] && _p9k_skip_until '\)'
        continue
      fi
    fi

    if [[ $token == *'$'* ]]; then
      local p='<->|[[:alpha:]_][[:IDENT:]]#'
      if [[ $token == ('$'$~p|'${'$~p'}'|'"$'$~p'"'|'"${'$~p'}"') ]]; then
        local name=${${token##[^[:IDENT:]]}%%[^[:IDENT:]]}
        [[ $token == *'"' ]] && local v=("${(@P)name}") || local v=(${(P)name})
        tokens[1,0]=(${(qq)v})
        continue
      fi
    fi

    _p9k_commands+=${token::=${(Q)${~token}}}

    # '|' '||' ';' '&' '&&' '|&' '&!' '&|' ';;' ';&' ';|' ')'
    _p9k_skip_until '\||\|\||;|&|&&|\|&|&!|&\||;;|;&|;\||\)|}'
    [[ $token == ';'(';'|'&'|'|') ]] && _p9k_skip_until '\)|esac'
  done
  true
}
