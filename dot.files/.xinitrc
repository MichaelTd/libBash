# ~/.xinitrc
#
# The dedicated WM hoppers ~/.xinitrc
#shellcheck shell=bash

# ~/.Xresources
[[ -f ~/.Xresources ]] && xrdb -I"${HOME}" -merge ~/.Xresources

# Silence terminal bell
xset b off

# Mouse acceleration
xset m 20/10 4

# Set NumLock ON
# setleds +num

# Qt5 theme engine
export QT_QPA_PLATFORMTHEME=qt5ct

declare -rA WMA=( [xfce4]="xfce4-session" \
                 [compiz]="compiz.sh" \
                 [enlightenment]="enlightenment_start" \
                 [e16]="starte16" \
                 [i3wm]="i3" \
                 [emacs]="emacs" )

# Selected WM (prefered WMA key available in daily driver)
declare -r SWM="i3wm"

# Per distro selection. If you've got preferences for specific distros, set them up here.
source /etc/os-release
if [[ "${ID}" == "gentoo" ]]; then
    WM="${WMA[$SWM]}"
elif [[ "${ID}" == "devuan" ]];then
    WM="${WMA[xfce4]}"
else
    # Availability check, One line version: WM=$( type -P xfce4-session||type -P compiz.sh||type -P enlightenment_start||type -P starte16||type -P openbox-session||type -P wmaker||type -P mwm||type -P awesome||type -P emacs ||type -P kodi-standalone )
    for x in "${!WMA[@]}"; do
        if [[ -x "$(type -P "${WMA[$x]}")" ]]; then
            WM="${WMA[$x]}"
            break
        fi
    done
fi

# Arguments check. If startx has an argument (eg: xfce4), set it up.
for y in "${@}"; do
    for z in "${!WMA[@]}"; do
        if [[ "${y}" =~ ${z} ]]; then
            WM="${WMA[$z]}"
            break
        fi
    done
done

# Per wm customizations. If there is a wm specific permutation to be done, here is the place.
if [[ "${WM[0]}" =~ emacs ]]; then
    # Just "emacs" would suffice if you don't mind a M-x:exwm-init on X boot.
    emacs --daemon # -f exwm-enable
    WM=( "emacsclient" "-c" )
elif [[ "${WM[0]}" =~ starte16 || "${WM[0]}" =~ enlightenment_start ]]; then
    # e17 svg support
    export E_COMP_ENGINE=sw
fi

# exec "${WM[@]}"
dbus-launch --exit-with-session "${WM[@]}"
