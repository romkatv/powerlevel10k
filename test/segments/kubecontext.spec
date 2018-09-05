#!/usr/bin/env zsh
#vim:ft=zsh ts=2 sw=2 sts=2 et fenc=utf-8

# Required for shunit2 to run correctly
setopt shwordsplit
SHUNIT_PARENT=$0

function setUp() {
  export TERM="xterm-256color"
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
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(kubecontext)
  alias kubectl=mockKubectl

  # Load Powerlevel9k
  source powerlevel9k.zsh-theme

  assertEquals "%K{005} %F{007}⎈ %f%F{007}minikube/default %k%F{005}%f " "$(build_left_prompt)"

  unalias kubectl
}
function testKubeContextOtherNamespace() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(kubecontext)
  alias kubectl=mockKubectlOtherNamespace

  # Load Powerlevel9k
  source powerlevel9k.zsh-theme

  assertEquals "%K{005} %F{007}⎈ %f%F{007}minikube/kube-system %k%F{005}%f " "$(build_left_prompt)"

  unalias kubectl
}
function testKubeContextPrintsNothingIfKubectlNotAvailable() {
  local -a POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(custom_world kubecontext)
  local POWERLEVEL9K_CUSTOM_WORLD='echo world'
  alias kubectl=noKubectl

  # Load Powerlevel9k
  source powerlevel9k.zsh-theme

  assertEquals "%K{007} %F{000}world %k%F{007}%f " "$(build_left_prompt)"

  unalias kubectl
}

source shunit2/shunit2
