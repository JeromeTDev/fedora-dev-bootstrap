if status is-interactive
    # Commands to run in interactive sessions can go here
set -x ANDROID_SDK_ROOT /home/woodz/Android/Sdk
set -x PATH $ANDROID_SDK_ROOT/emulator $ANDROID_SDK_ROOT/platform-tools $PATH


end
starship init fish | source

# Added by LM Studio CLI (lms)
set -gx PATH $PATH /home/woodz/.lmstudio/bin
# End of LM Studio CLI section


# opencode
fish_add_path /home/woodz/.opencode/bin
