#!/usr/bin/env zsh
#vim:ft=zsh ts=2 sw=2 sts=2 et fenc=utf-8

# Required for shunit2 to run correctly
setopt shwordsplit
SHUNIT_PARENT=$0

function setUp() {
  export TERM="xterm-256color"
  # Load Powerlevel9k
  source powerlevel9k.zsh-theme
}

function mockKubectl() {
  case "$1" in
    'version')
      echo 'non-empty text'
      ;;
    'config')
      case "$2" in
        'view')
          case "$3" in
            '-o=jsonpath={.current-context}')
              echo 'minikube'
              ;;
            '-o=jsonpath={.contexts'*)
              echo ''
              ;;
            *)
              echo "Mock value missed"
              exit 1
              ;;
          esac
          ;;
      esac
      ;;
  esac
}

function mockKubectlOtherNamespace() {
  case "$1" in
    'version')
      echo 'non-empty text'
      ;;
    'config')
      case "$2" in
        'view')
          case "$3" in
            # Get Current Context
            '-o=jsonpath={.current-context}')
              echo 'minikube'
              ;;
            # Get current namespace
            '-o=jsonpath={.contexts'*)
              echo 'kube-system'
              ;;
            *)
              echo "Mock value missed"
              exit 1
              ;;
          esac
          ;;
      esac
      ;;
  esac
}

function testKubeContext() {
  alias kubectl=mockKubectl
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(kubecontext)

  assertEquals "%K{magenta} %F{white%}⎈ %f%F{white}minikube/default %k%F{magenta}%f " "$(build_left_prompt)"

  unset POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  unalias kubectl
}
function testKubeContextOtherNamespace() {
  alias kubectl=mockKubectlOtherNamespace
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(kubecontext)

  assertEquals "%K{magenta} %F{white%}⎈ %f%F{white}minikube/kube-system %k%F{magenta}%f " "$(build_left_prompt)"

  unset POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  unalias kubectl
}
function testKubeContextPrintsNothingIfKubectlNotAvailable() {
  alias kubectl=noKubectl
  POWERLEVEL9K_CUSTOM_WORLD='echo world'
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(custom_world kubecontext)

  assertEquals "%K{white} %F{black}world %k%F{white}%f " "$(build_left_prompt)"

  unset POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  unset POWERLEVEL9K_CUSTOM_WORLD
  unalias kubectl
}

source shunit2/source/2.1/src/shunit2
