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
#   - -- x
#   ---------------
#   command -p -p x
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
  
  local -r id='(<->|[[:alpha:]_][[:IDENT:]]#)'
  local -r var="\$$id|\${$id}|\"\$$id\"|\"\${$id}\""

  local -i e c=1024
  local skip n s r state
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
          (( e = $#state ))
        fi
      else
        (( e = $#state ))
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

      case $state in
        t|p*)
          if (( $+_p9k_term[$token] )); then
            skip=$_p9k_skip_arg[$token]
            state=${skip:+s}
            [[ $token == '()' ]] || _p9k_commands+=($commands)
            commands=()
            continue
          elif [[ $state == t ]]; then
            continue
          fi;;
        s)
          if [[ $token == $~skip ]]; then
            state=
          fi
          continue;;
        *r)
          state[1]=
          continue;;
        h)
          skip=${(b)token}
          state=s
          continue;;
      esac

      if [[ $token == '<<'(|-) ]]; then
        state=h
        continue
      fi

      if (( $+_p9k_redirect[${token#<0-255>}] )); then
        state+=r
        continue
      fi

      if [[ $token == *'$'* ]]; then
        if [[ $token == $~var ]]; then
          n=${${token##[^[:IDENT:]]}%%[^[:IDENT:]]}
          [[ $token == *'"' ]] && v=("${(@P)n}") || v=(${(P)n})
          tokens[1,0]=(${(qq)v})
          continue
        fi
      fi

      case $state in
        '')
          if (( $+_p9k_skip_token[$token] )); then
            skip=$_p9k_skip_token[$token]
            state=${skip:+s}
            continue
          fi
          if [[ $token == *=* ]]; then
            v=${(S)token/#(<->|([[:alpha:]_][[:IDENT:]]#(|'['*[^\\](\\\\)#']')))(|'+')=}
            if (( $#v < $#token )); then
              if [[ $v == '(' ]]; then
                state=s
                skip='\)'
              fi
              continue
            fi
          fi
          : ${token::=${(Q)${~token}}};;
        p)
          : ${token::=${(Q)${~token}}}
          case $token in
            [^-]*)                    ;;
            --)     state=p1; continue;;
            $~skip) state=p2; continue;;
            *)                continue;;
          esac;;
        p1) ;;
        p2)
          state=p
          continue;;
      esac

      commands+=$token
      if (( $+_p9k_precomands[$commands[-1]] )); then
        state=p
        skip=$_p9k_precomands[$commands[-1]]
      else
        state=t
      fi
    done
  }

  _p9k_commands+=($commands)
  _p9k_commands=(${(u)_p9k_commands:#('(('*'))'|'`'*'`'|'$'*)})
}
