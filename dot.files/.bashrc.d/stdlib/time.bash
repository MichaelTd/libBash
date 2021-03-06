#
# date, time related functions
#shellcheck shell=bash disable=SC2120,SC2119

is_date() {
    [[ -z "${1}" ]] && return 1  # apparently `date -d ""` echoes today's day and returns 0
    date -d "${1}" &> /dev/null
}

is_epoch() {
    date -d "@${1}" &> /dev/null
}

# https://www.unix.com/tips-and-tutorials/31944-simple-date-time-calulation-bash.html
time_diff() {
    case "${1}" in
        -s) shift; local -r sec="1";;
        -m) shift; local -r sec="60";;
        -h) shift; local -r sec="$((60 * 60))";;
        -d) shift; local -r sec="$((60 * 60 * 24))";;
        *) local -r sec="$((60 * 60 * 24))";;
    esac
    if is_date "${1}" && is_date "${2}"; then
	local -r ep1="$(date -d "$1" "+%s")" ep2="$(date -d "$2" "+%s")"
	local -r sec_diff="$((ep2 - ep1))"
	if ((sec_diff < 0)); then local -r mult=-1; else local -r mult=1; fi
	echo "$((sec_diff * mult / sec))"
    else
	echo -ne "Usage: ${FUNCNAME[0]} [-s|-m|-h|-d(default)] date1 date2.\n" >&2
	return 1
    fi
}

epoch_diff() {
    if [[ "${#}" -eq "2" ]] && is_epoch "${1}" && is_epoch "${2}"; then
	local -r diff="$((($1-$2)/(60*60*24)))"
	if ((diff < 0)); then local -r mult=-1; else local -r mult=1; fi
	echo "$((mult * diff))"
    else
	echo -ne "Usage: ${FUNCNAME[0]} epoch1 epoch2.\n" >&2
	return 1
    fi
}

date_diff() {
    if [[ "${#}" -eq "2" ]] && is_date "${1}" && is_date "${2}"; then
	epoch_diff "$(date -d "${1}" +%s)" "$(date -d "${2}" +%s)"
    else
	echo -ne "Usage: ${FUNCNAME[0]} date1 date2.\n" >&2
	return 1
    fi
}

unix_epoch() {
    if [[ -n "${1}" ]]; then
	date -d "${1}" +%s
    else
	date -u +%s
    fi
}

epoch2date() {
    date -d "@${1-$(unix_epoch)}" "+%F"
}

epoch2time() {
    date -d "@${1-$(unix_epoch)}" "+%T"
}

epoch2datetime() {
    date -d "@${1-$(unix_epoch)}" "+%F %T"
}

week_day() {
    date -d "@${1:-$(unix_epoch)}" "+%u"
}

leap_year() {
    # https://en.wikipedia.org/wiki/Leap_year
    # if (year is not divisible by 4) then (it is a common year)
    # else if (year is not divisible by 100) then (it is a leap year)
    # else if (year is not divisible by 400) then (it is a common year)
    # else (it is a leap year)
    # https://stackoverflow.com/questions/3220163/how-to-find-leap-year-programatically-in-c/11595914#11595914
    # https://www.timeanddate.com/date/leapyear.html
    # https://medium.freecodecamp.org/test-driven-development-what-it-is-and-what-it-is-not-41fa6bca02a2

    if [[ -z "${1}" ]]; then
	echo -ne "Usage: ${FUNCNAME[0]} #year\n" >&2
	return 2
    else
	if (($1 % 4 != 0)); then return 1
	elif (($1 % 100 != 0)); then return 0
	elif (($1 % 400 != 0)); then return 1
	else return 0
	fi
    fi
}

last_dom() {
    local y m
    if [[ -n "${1}" ]] && is_date "${1}"; then
	y="$(date -d "${1}" +%Y)"
	m="$(date -d "${1}" +%m)"
    else
	echo -ne "Usage: ${FUNCNAME[0]} iso_date (ie: YYYY-MM-DD, eg: date +%F)\n" >&2
	return 2
    fi
    
    case "${m}" in
	"01"|"03"|"05"|"07"|"08"|"10"|"12") echo "31";;
	"02") leap_year "${y}" && echo "29" || echo "28";;
	"04"|"06"|"09"|"11") echo "30";;
    esac
}
