#!/usr/bin/env bash
#
# ~/bin/screenshot.sh
# Take a screenshot. Requires Imagemagic or scrot, ristretto or viewnior.

FN="${HOME}/ss-$(date +%s).png"

#shellcheck disable=SC2015
import -delay 2 -window root "${FN}" || scrot --delay 2 "${FN}" && ristretto "${FN}" || viewnior "${FN}"
