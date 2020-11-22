# Extensible

If there is no prompt segment that does what you need, implement your own. Powerlevel10k provides
public API for defining segments that are as fast and as flexible as built-in ones.

![Powerlevel10k Custom Segment](https://raw.githubusercontent.com/romkatv/powerlevel10k-media/master/custom-segment.gif)

On Linux you can fetch current CPU temperature by reading `/sys/class/thermal/thermal_zone0/temp`.
The screencast shows how to define a prompt segment to display this value. Once the segment is
defined, you can use it like any other segment. All standard customization parameters will work for
it out of the box.

Type `p10k help segment` for reference.

_Tip_: Prefix names of your own segments with `my_` to avoid clashes with future versions of
Powerlevel10k.
