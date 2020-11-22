# Show on command

The behavior of some commands depends on global environment. For example, `kubectl run ...` runs an
image on the cluster defined by the current kubernetes context. If you frequently change context
between "prod" and "testing", you might want to display the current context in Zsh prompt. If you do
likewise for AWS, Azure and Google Cloud credentials, prompt will get pretty crowded.

Enter _Show On Command_. This feature makes prompt segments appear only when they are relevant to
the command you are currently typing.

![Powerlevel10k Show On Command](https://raw.githubusercontent.com/romkatv/powerlevel10k-media/master/show-on-command.gif)

Configs created by `p10k configure` enable show on command for several prompt segments by default.
Here's the relevant parameter for kubernetes context:

```zsh
# Show prompt segment "kubecontext" only when the command you are typing
# invokes kubectl, helm, kubens, kubectx, oc, istioctl, kogito, k9s or helmfile.
typeset -g POWERLEVEL9K_KUBECONTEXT_SHOW_ON_COMMAND='kubectl|helm|kubens|kubectx|oc|istioctl|kogito|k9s|helmfile'
```

To customize when different prompt segments are shown, open `~/.p10k.zsh`, search for
`SHOW_ON_COMMAND` and either remove these parameters to display affected segments unconditionally,
or change their values.
