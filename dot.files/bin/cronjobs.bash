#!/bin/bash
#
# ~/bin/cronjobs.bash
# gather cronjobs for use with a familiar environment (/bin/bash)

usage="Usage: $(basename "${BASH_SOURCE[0]}") [-(-a)larm] | [-(-b)ackup]"

alarm() {
    cvlc --random file:///mnt/data/Documents/Music/Stanley-Clarke/ file:///mnt/data/Documents/Music/Marcus-Miller/ file:///mnt/data/Documents/Music/Jaco-Pastorius/ file:///mnt/data/Documents/Music/Esperanza-Spalding/ file:///mnt/data/Documents/Music/Mark-King/Level\ Best/
}

backup() {
    local bkpt="/mnt/el/Documents/BKP/LINUX/${USER}" bkpd="${HOME}" \
          xcldf="${HOME}/.bkp.exclude" rcpnt="tsouchlarakis@gmail.com"
    local outfl="${bkpt}/$(date +%y%m%d).$(date +%s).${USER}.tar.gz.pgp" \
          LS="$(type -P ls)"
    # Just in case
    mkdir -p "${bkpt}"
    # Bkp & encrypt things.
    nice -n 9 tar -cz --exclude-from="${xcldf}" \
         --exclude-backups --one-file-system "${bkpd}"/. \
        | gpg2 --batch --yes --quiet --recipient "${rcpnt}" \
               --trust-model always --output "${outfl}" --encrypt
    
    # Keep two most recent bkps
    ~/sbin/cleanup_bkps.sh -d "${bkpt}" -s -k 2
}

main() {
    if [[ -z "${1}" ]]; then
	echo "${usage}" >&2; exit 1
    else
	while [[ -n "${1}" ]]; do
            case "${1}" in
		"-a"|"--alarm") alarm;;
		"-b"|"--backup") backup;;
		*) echo "${usage}" >&2; exit 1;;
            esac
            shift
	done
    fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "${@}"
fi