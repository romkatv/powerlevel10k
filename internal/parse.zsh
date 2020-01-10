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
  
  local -i e
  local id='$(<->|[[:alpha:]_][[:IDENT:]]#)'
  local skip n s r var="\$$id|\${$id}|\"\$$id\"|\"\${$id}\""
  local -a aln alp alf v match mbegin mend

  [[ -o interactive_comments ]] && local tokens=(${(Z+C+)1}) || local tokens=(${(z)1})

  while (( $#tokens )); do
    if (( $#tokens == aln[-1] )); then
      aln[-1]=()
      alp[-1]=()
      if (( $#tokens == alf[-1] )); then
        alf[-1]=()
        e=0
      else
        e=$#skip
      fi
    else
      e=$#skip
    fi

    while (( $#tokens )) || break; do
      token=$tokens[1]
      shift 1 tokens
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

    if [[ -n $skip ]]; then
      if [[ $token == $~skip ]]; then
        [[ $token == ';'[';&|'] ]] && skip='\)|esac' || skip=
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

    _p9k_commands+=${token::=${(Q)${~token}}}

    # '|' '||' ';' '&' '&&' '|&' '&!' '&|' ';;' ';&' ';|' ')'
    skip='\||\|\||;|&|&&|\|&|&!|&\||;;|;&|;\||\)|}'
  done
}
