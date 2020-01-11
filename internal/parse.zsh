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
  'else' ''
  'then' ''
  'while' ''
  'until' ''
  'do' ''
  'done' ''
  'esac' ''
  'end' ''
  'coproc' ''
  'nocorrect' ''
  'noglob' ''
  'time' ''
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
  '<<<' '*'
  'foreach' '\(*\)'
)

typeset -gA _p9k_precomands=(
  '-' ''
  'builtin' ''
  'command' ''
  'exec' '-[^a]#[a]'
  'nohup' ''
  'setsid' ''
  'eatmydata' ''
  'catchsegv' ''
  'pkexec' '--user'
  'doas' '-[^aCu]#[acU]'
  'nice' '-[^n]#[n]|--adjustment'
  'stdbuf' '-[^ioe]#[ioe]|--(input|output|error)'
  'sudo' '-[^aghpuUCcrtT]#[aghpuUCcrtT]|--(close-from|group|host|prompt|role|type|other-user|command-timeout|user)'
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
  '<<<' ''
)

typeset -gA _p9k_term=(
  '|' ''
  '||' ''
  ';' ''
  '&' ''
  '&&' ''
  '|&' ''
  '&!' ''
  '&|' ''
  ';;' ''
  ';&' ''
  ';|' ''
  '(' ''
  ')' ''
  '{' ''
  '}' ''
  '()' ''
)

typeset -gA _p9k_skip_arg=(
  ';;' '\)|esac'
  ';&' '\)|esac'
  ';|' '\)|esac'
  '(' '\)'
  '()' ''
)

function _p9k_next_token() {
  if (( $#tokens )); then
    if (( $#tokens == aln[-1] )); then
      aln[-1]=()
      alp[-1]=()
      if (( $#tokens == alf[-1] )); then
        alf[-1]=()
        (( e = 0 ))
      else
        (( e = 1 ))
      fi
    else
      (( e = 1 ))
    fi

    while (( c-- > 0 )); do
      token=$tokens[1]
      tokens[1]=()
      if (( $+galiases[$token] )); then
        (( $aln[(eI)p$token] )) && return
        n=p$token
        s=$galiases[$token]
      elif (( e )); then
        return
      elif (( $+aliases[$token] )); then
        (( $aln[(eI)p$token] )) && return
        n=p$token
        s=$aliases[$token]
      elif [[ $token == (#b)?*.(?*) ]] && (( $+saliases[$match[1]] )); then
        (( $aln[(eI)s$match[1]] )) && return
        n=s$match[1]
        s=${saliases[$match[1]]%% #}
      else
        return 0
      fi
      aln+=$n
      alp+=$#tokens
      [[ $s == *' ' ]] && alf+=$#tokens
      [[ -o interactive_comments ]] && tokens[1,0]=(${(Z+C+)s}) || tokens[1,0]=(${(z)s})
    done
  fi

  token=
  return 1
}

# False positives:
#
#   {} always {}
#
# False negatives:
#
#   ---------------
#   : $(x)
#   ---------------
#   : `x`
#   ---------------
#
# Broken:
#
#   ---------------
#   ${x/}
#   ---------------
#   *
#   ---------------
#   x=$y; $x
#   ---------------
#   x <<END
#   ; END
#   END
#   ---------------
#   Setup:
#     setopt interactive_comments
#     alias x='#'
#   Punchline:
#     x; y
#   ---------------
function _p9k_extract_commands() {
  local rcquotes
  [[ -o rcquotes ]] && rcquotes=(-o rcquotes)

  emulate -L zsh -o extended_glob -o no_nomatch $rcquotes

  typeset -ga _p9k_commands=()
  
  local -r id='$(<->|[[:alpha:]_][[:IDENT:]]#)'
  local -r var="\$$id|\${$id}|\"\$$id\"|\"\${$id}\""

  local -i e c=32
  local skip n s r
  local -a aln alp alf v commands match mbegin mend

  [[ -o interactive_comments ]] && local tokens=(${(Z+C+)1}) || local tokens=(${(z)1})

  () {
    while (( $#tokens )); do
      if (( $#tokens == aln[-1] )); then
        aln[-1]=()
        alp[-1]=()
        if (( $#tokens == alf[-1] )); then
          alf[-1]=()
          (( e = 0 ))
        else
          (( e = $#skip ))
        fi
      else
        (( e = $#skip ))
      fi

      while (( c-- > 0 )) || return; do
        token=$tokens[1]
        tokens[1]=()
        if (( $+galiases[$token] )); then
          (( $aln[(eI)p$token] )) && break
          n=p$token
          s=$galiases[$token]
        elif (( e )); then
          break
        elif (( $+aliases[$token] )); then
          (( $aln[(eI)p$token] )) && break
          n=p$token
          s=$aliases[$token]
        elif [[ $token == (#b)?*.(?*) ]] && (( $+saliases[$match[1]] )); then
          (( $aln[(eI)s$match[1]] )) && break
          n=s$match[1]
          s=${saliases[$match[1]]%% #}
        else
          break
        fi
        aln+=$n
        alp+=$#tokens
        [[ $s == *' ' ]] && alf+=$#tokens
        [[ -o interactive_comments ]] && tokens[1,0]=(${(Z+C+)s}) || tokens[1,0]=(${(z)s})
      done

      if [[ $token == '<<'(|-) ]]; then
        _p9k_next_token || return
        r=$token
        while true; do
          while _p9k_next_token && [[ $token != ';' ]]; do done
          while _p9k_next_token && [[ $token == ';' ]]; do done
          [[ $token == (|$r) ]] && break
        done
        continue
      fi

      if [[ -n $skip ]]; then
        if [[ $skip == ']' ]]; then
          if (( $+_p9k_term[$token] )); then
            skip=$_p9k_skip_arg[$token]
            [[ $token == '()' ]] || _p9k_commands+=($commands)
            commands=()
          fi
        elif [[ $token == $~skip ]]; then
          skip=
        fi
        continue
      fi

      r=${token#<0-255>}
      if (( $+_p9k_skip_token[$r] )); then
        if (( $+_p9k_skip_token[$token] )); then
          skip=$_p9k_skip_token[$token]
          continue
        fi
        if (( $+_p9k_redirect[$r] )); then
          skip='*'
          continue
        fi
      fi

      if [[ $token == *=* ]]; then
        v=${(S)token/#(<->|([[:alpha:]_][[:IDENT:]]#(|'['*[^\\](\\\\)#']')))(|'+')=}
        if (( $#v < $#token )); then
          [[ $v == '(' ]] && skip='\)'
          continue
        fi
      fi

      if [[ $token == *'$'* ]]; then
        if [[ $token == $~id ]]; then
          n=${${token##[^[:IDENT:]]}%%[^[:IDENT:]]}
          [[ $token == *'"' ]] && v=("${(@P)n}") || v=(${(P)name})
          tokens[1,0]=(${(qq)v})
          continue
        fi
      fi

      commands+=${:-${(Q)${~token}}}
      skip=']'
    done
  }

  _p9k_commands+=($commands)
  _p9k_commands=(${(u)_p9k_commands:#('(('*'))'|'`'*'`'|'$'*)})
}
