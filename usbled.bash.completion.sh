# Bash completion file for usbled
_usbled() {
	local cur prev words cword
	_init_completion || return

	if [[ $cword -eq 1 ]] ; then
		COMPREPLY=( $( compgen -W "-l $(usbled -l)" -- "$cur") )
	else
		COMPREPLY=()
	fi

	return 0
}
complete -F _usbled usbled
