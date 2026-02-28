# License at bottom.

# Bail if not interactive
[[ $- == *i* ]] || return 0

# Globals
declare -a cdlog_hist             # directory history
declare -A cdlog_alias            # cd aliases

unset cdlog_alias[0]              # history is 1-based

# Configuration variables
cdlog_lru=${cdlog_lru-}
cdlog_sess_dir=${cdlog_sess_dir-~}
cdlog_autorecover=${cdlog_autorecover-}

# Set state from args
cdlog.args()
{
  c1=$1; c2=$2; c3=$3
  c4=$4; c5=$5; c6=$6
  c7=$7; c8=$8; c9=$9

  x=$c1
  y=$c2
  z=$c3
  w=$c4
}

# Update after history change.
cdlog.update()
{
  declare -n d=cdlog_hist
  cdlog.args "${d[@]}"

  # Persist to disk.
  cat > "$cdlog_dirs" <<!
$PWD
$(printf "%s\n" "${d[@]}")
!
}

# Utility for nth positional param
cdlog.get_param()
{
  if shift $1 ; then
    echo "$1"
  fi
}

# Initialize state, allocating new ~/.cdlog.N.dirs storage,
# with LRU replacement.
cdlog.init()
{
  local i
  local oldest
  local context
  local csd=$cdlog_sess_dir
  declare -n d=cdlog_hist

  mkdir -p "$csd"

  for ((i = 0; i < ${#d[@]}; i++)); do
    unset d[$i]
  done

  cdlog_dirs=
  context=

  for i in {1..10}; do
    if ! [ -f "$csd"/.cdlog.$i.dirs ] ; then
      context=$i
      break
    fi
  done

  if ! [ $context ] ; then
    oldest=1
    for i in {2..10}; do
      if [ "$csd"/.cdlog.$i.dirs -ot "$csd"/.cdlog.$oldest.dirs ] ; then
        oldest=$i
      fi
    done
    context=$oldest
  fi

  cdlog_dirs="$csd"/.cdlog.$context.dirs
  cdlog_new_dirs=$cdlog_dirs
  rm -f $cdlog_dirs

  set -- "$csd"/.cdlog.*.dirs
  if [ $# -gt 0 -a $1 != "$csd"/.cdlog.'*'.dirs ] ; then
    if [ "$cdlog_autorecover" -a $# -eq 1 -a \
          \( "$SHLVL" == 1 -o "${0%%[a-z]*}" == "-" \) ]
    then
      cdlog.recover __auto
    else
      printf "Use 'cdr' or 'cdlog.recover' to switch to prior cdlog context.\n"
    fi
  fi

  # Also init var nicknames, but don't save context
  cdlog.args "${d[@]}"
}

cdlog.recover()
{
  local dirs
  local i
  local sel
  local csd=$cdlog_sess_dir
  local auto=$1
  local print=

  mkdir -p "$csd"

  set -- "$csd"/.cdlog.*.dirs
  if [ $# -eq 1 -a $1 == "$csd"/.cdlog.'*'.dirs ] ; then
    : # nothing
  elif [ $# -eq 1 -a "$auto" == __auto ] ; then
    printf "Auto-recovering cdlog session 1.\n"
    cdlog_dirs=$(cdlog.get_param 1 "$@")
    print=y
  else
    printf "These cdlog contexts exist in %s:\n" "$csd"
    i=0
    for dirs in "$@"; do
      printf "[%d]: %s%s\n" $((++i)) \
             "$([ "$dirs" = "$cdlog_dirs" ] && printf "[current] ")" \
             "$(date -r "$dirs")"
      sed -e '/^$/d' "$dirs" | head -9
    done

    while true; do
      if [ $i -eq 1 ] ; then
        printf "Use 1 to select context, c1 to clone,\n"
      else
        printf "Use 1-%s to select context,\n" $i
        printf "c1-c%s to clone,\n" $i
        printf "d1-d%s to delete,\n" $i
        printf "n to use newly allocated,\n" $i
      fi
      printf "or Enter to keep current context: "
      read sel
      case $sel in
      ( [1-9] )
        sel=$(cdlog.get_param $sel "$@")
        if [ -n "$sel" ] ; then
          cdlog_dirs=$sel
          break
        fi
        ;;
      ( c[1-9] )
        sel=$(cdlog.get_param ${sel#c} "$@")
        if [ -n "$sel" ] ; then
          cp "$sel" "$cdlog_dirs"
          break
        fi
        ;;
      ( d[1-9] )
        sel=$(cdlog.get_param ${sel#d} "$@")
        if [ -n "$sel" ] ; then
          rm "$sel" && printf "Deleted!\n"
        fi
        ;;
      ( n )
        cdlog_dirs=$cdlog_new_dirs
        break
        ;;
      ( "" )
        break
        ;;
      esac
    done
  fi

  if [ -f "$cdlog_dirs" ] ; then
    mapfile -t cdlog_hist < "$cdlog_dirs"
    command cd "${cdlog_hist[0]}"
    unset cdlog_hist[0]
    cdlog.update
  fi

  [ $print ] && printf "%s\n" "$PWD"
  return 0
}

# Resolve @ search item to number
cdlog.at2index()
{
  local i
  local pat=${1#@}

  for i in "${!cdlog_hist[@]}"; do
    if [[ ${cdlog_hist[$i]} =~ $pat ]] ; then
      echo $i
      return 0
    fi
  done
  return 1
}

# Resolve @ search item to path
cdlog.at2path()
{
  local i
  local pat=${1#@}

  for i in "${!cdlog_hist[@]}"; do
    local path=${cdlog_hist[$i]}
    if [[ $path =~ $pat ]] ; then
      echo $path
      return 0
    fi
  done
  return 1
}

# Change to directory: this is aliased to cd command.
cdlog.chdir()
{
  local cur=$PWD
  local def
  local print=
  declare -n d=cdlog_hist

  if [ $# -eq 2 -a "$1" = -P ] ; then
    case $2 in
    ( @* )
      if def=$(cdlog.at2path "$2"); then
        set -- -P "$def"
        print=y
      else
        printf "cdlog.chdir: no match for %s\n" "$2"
        return 1
      fi
      ;;
    ( */* )
      ;;
    ( [1-9] )
      set -- -P "${d[$2]}"
      print=y
      ;;
    ( ?* )
      def=${cdlog_alias[$2]}
      if [ -n "$def" ] ; then
        set -- -P "$def"
        print=y
      fi
      ;;
    ( * )
      return 0
      ;;
    esac
  fi

  if command cd "$@" && [ "$PWD" != "$cur" ]; then
    # only if we successfully change to a different
    # directory do the following
    [ $print ] && printf "%s\n" "$PWD"

    if [ $cdlog_lru ] ; then
      local nx=
      local pv=$cur
      local i
      local n1=$((${#d[@]} + 1))

      for ((i = 1; i <= n1; i++)); do
        nx=${d[$i]}
        d[$i]=$pv
        if [ "$nx" = "$PWD" ] ; then
          break
        fi
        pv=$nx
      done
    else
      for ((i = ${#d[@]}; i >= 1; i--)); do
        d[$((i+1))]=${d[$i]}
      done

      d[1]=$cur
    fi

    cdlog.update
  fi
}

# Rotate through specified directories.
cdlog.rot()
{
  local cur=$PWD
  local p=$cur
  local n=$cur
  local i
  declare -n d=cdlog_hist
  local first=y

  [ $# -gt 0 ] || set 1

  while [ $# -gt 0 ] ; do
    n=$1; shift
    while true; do
      case $n in
      ( [1-9] )
        if [ $first ] ; then
          command cd "${d[$n]}" || return
          printf "%s\n" "$PWD"
        else
          d[$p]=${d[$n]}
        fi
        first=
        p=$n
        ;;
      ( * )
        if i=$(cdlog.at2index "$n"); then
          n=$i
          continue
        else
          printf "cdlog.rot: no match for %s\n" "$n"
          return 1
        fi
        ;;
      esac
      break
    done
  done

  d[$p]=$cur

  cdlog.update
}


# Change to most recent directory in cdlog and remove it
# from the log.
cdlog.pop()
{
  declare -n d=cdlog_hist
  local n=1
  local i
  local force=

  if [ $# -gt 0 -a "$1" = "-f" ] ; then
    force=y; shift
  fi

  if [ $# -gt 0 ] ; then
    n=$1; shift
  fi

  case $n in
  ( [1-9] )
    if command cd "${d[$n]}" || [ $force ]; then
      for ((i = n; i < ${#d[@]}; i++)); do
        d[$i]=${d[$((i + 1))]}
      done
      unset d[$i]
      cdlog.update
      printf "%s\n" "$PWD"
    fi
    ;;
  ( * )
    printf "cdlog.pop: bad argument: %s\n" "$n"
    return 1
    ;;
  esac
}

# Print four recent cdlog entries.
cdlog()
{
  printf "1: %s\n" "$c1"
  printf "2: %s\n" "$c2"
  printf "3: %s\n" "$c3"
  printf "4: %s\n" "$c4"

  if [ "${1-}" = "-l" ] ; then
    printf "5: %s\n" "$c5"
    printf "6: %s\n" "$c6"
    printf "7: %s\n" "$c7"
    printf "8: %s\n" "$c8"
    printf "9: %s\n" "$c9"
  fi
}

# Menu-based cd/cs.
cdlog.mcd()
{
  local sel=
  local swap=
  local res=1
  local i
  declare -n d=cdlog_hist

  if [ $# -gt 0 ] && [ "$1" = -s ] ; then
    swap=y
  fi

  for i in {1..9}; do
    printf "%s: %s\n" $i "${d[$i]}"
  done

  read -p "? " sel

  for i in {1..10}; do
    printf "\e[A\e[K"
  done

  while true; do
    case "$sel" in
    ( [1-9] )
      if [ $swap ] ; then
        cdlog.rot $sel
      else
        if cdlog.chdir -P "${d[$sel]}" ; then
          printf "%s\n" "$PWD"
        fi
      fi
      res=$?
      ;;
    ( * )
      if i=$(cdlog.at2index "$sel"); then
        sel=$i
        continue
      else
        printf "cdlog.mcd: no match for %s\n" "$sel"
        return 1
      fi
    esac
    break
  done

  return $res
}

cdlog.alias()
{
  local def=

  case $# in
  ( 0 )
    cdlog.aliases
    return $?
    ;;
  ( 1 )
    if [ ${cdlog_alias[$1]+y} ] ; then
      printf "%s -> %s\n" "$1" "${cdlog_alias[$1]}"
      return 0
    else
      printf "cdlog.alias; %s: not defined\n" "$1"
      return 1
    fi
    ;;
  ( 2 )
    ;;
  ( * )
    printf "cdlog.alias: one or two arguments required\n"
    return 1
    ;;
  esac

  if [ -z "$1" ] ; then
    printf "cdlog.alias: alias may not be empty\n"
    return 1
  fi

  def=$2

  case "$def" in
  ( @* )
    if ! def=$(cdlog.at2path "$2"); then
      printf "cdlog.alias: no match for %s\n" "$2"
      return 1
    fi
    ;;
  ( [1-9] )
    def=${cdlog_hist[$2]}
    if [ -z "$def" ] ; then
      printf "cdlog.alias: %s position empty\n" "$2"
      return 1
    fi
    ;;
  ( * )
    def=$2
    ;;
  esac

  cdlog_alias[$1]=$def
  return 0
}

cdlog.aliases()
{
  local alias

  for alias in "${!cdlog_alias[@]}"; do
    printf "%s -> %s\n" "$alias" "${cdlog_alias[$alias]}"
  done
}

cdlog.unalias()
{
  local alias

  for alias in "$@"; do
    if [ "${cdlog_alias[$alias]+y}" == y ]; then
      unset cdlog_alias[$alias]
    else
      printf "no such cdlog alias: %s\n" "$alias"
    fi
  done
}

cdlog.lookup()
{
  local out

  case $1 in
  ( [1-9] )
    out=${cdlog_hist[$1]}
    [ -n "$out" ] && printf "%s\n" "$out" || false
    ;;
  ( @* )
    cdlog.at2path "$1"
    ;;
  ( * )
    out=${cdlog_alias[$1]}
    [ -n "$out" ] && printf "%s\n" "$out" || false
    ;;
  esac
}


# Tab completion for cd aliases

cdlog.complete()
{
  COMPREPLY=()
  local cur=${COMP_WORDS[COMP_CWORD]}
  local alias
  local dir

  compopt -o nospace

  COMPREPLY+=( $(compgen -d -- "$cur") )

  for alias in "${!cdlog_alias[@]}"; do
    case "$alias" in
    ( "$cur"* )
      COMPREPLY+=( "$alias" )
      ;;
    esac
  done

  IFS=':' set -- $CDPATH
  for dir in "$@"; do
    COMPREPLY+=( $(compgen -d -- "$dir/$cur") )
  done

  return  0
}

# Aliases.
alias cd='cdlog.chdir -P'
alias pd='cdlog.pop'
alias cs='cdlog.rot'
alias cl='cdlog'
alias cll='cdlog -l'
alias mcd='cdlog.mcd'
alias mcs='cdlog.mcd -s'
alias cdr='cdlog.recover'
alias cdalias='cdlog.alias'
alias cdaliases='cdlog.aliases'
alias cdunalias='cdlog.unalias'
alias c='cdlog.lookup'

# Better completion for $x[Tab]
shopt -s direxpand

# Initialize cdlog the first time.

c1=${c1-}

if [ -z "$c1" -o -z "$cdlog_dirs" ] ; then
  cdlog.init
fi

# Register completion
complete -F cdlog.complete cd

# Copyright 2024-2025
# Kaz Kylheku <kaz@kylheku.com>
# Vancouver, Canada
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following condition is met:
#
# 1. Redistributions of source code must retain the above copyright notice, this
#    list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form need not reproduce any copyright notice.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
