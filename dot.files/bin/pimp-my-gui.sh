#!/usr/bin/env bash
#
# ~/bin/pimp-my-gui
# Spice for my desktop

# Run things in the background with custom niceness and cli switches in a mutex kind of way
# Usage : custom_run niceness executable command line arguments
function custom_run {
  bin=$(which "${2}")
  pid=$(pidof "${2}")
  if [[ -z "${pid}" && -x "${bin}" ]]; then
    nice -n "${@}" &
  fi
}

# custom_run 19 compton # Start an X11 compositor

#source /etc/os-release # Work around conky versions (pre/post 1.9)

custom_run 19 conky >> /dev/null 2>&1 # Monitor your box

custom_run 19 xscreensaver -no-splash # XScreenSaver

custom_run 19 orage # A calendar app # pgrep will produce erratic results, so no custom_run here # pidof fixed that

nice -n 19 wicd-gtk -t & # Networking # Python gui

nice -n 9 terminology & # Start a terminal

# nice -n 9 xfce4-terminal --disable-server & # Start a terminal

nice -n 9 ${HOME}/bin/TkRootMenu & # Start a Menu # Python based gui

source "${HOME}/.bashrc.d/wallpaper-rotate.sh" # Add some wallpaper variety for your desktop
wallpaper_rotate &