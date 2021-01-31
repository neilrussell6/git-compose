#!/usr/bin/env bash

# --------------------------------------
# print constants
# --------------------------------------

LIGHTER_GREY=246
LIGHT_GREY=244
GREY=243
DARK_GREY=237
DARKER_GREY=235
BLACK=233

BLUE=4
GOLD=214
LIGHTBLUE=74
LIME=106
RED=124
LIGHTRED=202
PINK=219
WHITE=255
PURPLE=99

DETAULT_THEME=$LIME

BOLD=1
DIM=2
ITALIC=3
UNDERLINED=4
NORMAL=5

RESET="\033[0m"

# --------------------------------------
# print utils
# --------------------------------------

function _getBG() {
  echo "\033[48;5;${1}m"
}

function _getFG() {
	local mod="${!2:-$NORMAL}"
  echo "\033[${mod};38;5;${1}m"
}

function _print() {
	printf '%b%b %s %b' $1 $2 "${3}" $RESET
}

function h1() {
	local color="${!2:-$DETAULT_THEME}"
	_print $(_getBG $color) $(_getFG $BLACK BOLD) "${1}"
}

function h2() {
	local color="${!2:-$DETAULT_THEME}"
	_print $(_getBG $BLACK) $(_getFG $color) "${1}"
}

function h3() {
	local color="${!2:-$DETAULT_THEME}"
	_print $(_getBG $BLACK) $(_getFG $LIGHTER_GREY BOLD) "${1}"
}

function print() {
	local color="${!2:-$DETAULT_THEME}"
	local mod="${3:-NORMAL}"
	_print $RESET $(_getFG $color $mod) "${1}"
}

# --------------------------------------
# env
# --------------------------------------

# Load up .env
set -o allexport
[[ -f .env ]] && source .env
set +o allexport

# --------------------------------------
# vars
# --------------------------------------

#DIR_SYMBOL=" +--"
DIR_SYMBOL=" -"
DIR_SPACER=" |"
ROOT_BRANCH="${ROOT_BRANCH:-master}"

BRANCH_STATUS_NO_REMOTE=0
BRANCH_STATUS_REMOTE=1
BRANCH_STATUS_CURRENT=2

TREE=()
TREE+=("${ROOT_BRANCH}")
PWD=$(pwd)
PARENT_BRANCH=""
CURRENT_BRANCH=$(git symbolic-ref HEAD | sed -e 's,.*/\(.*\),\1,')

# --------------------------------------
# set parent branch and tree
# $1 BRANCH
#
# figure out the parent branch
# using the TREE array of previous branches
# and provided branch's name
# --------------------------------------

set_parent_branch () {
  local BRANCH=$1
  local LAST_BRANCH=""
  if [[ ${#TREE[@]} -eq 1 ]] ; then
    TREE+=("${BRANCH}")
    PARENT_BRANCH="${ROOT_BRANCH}"
  else
    LAST_BRANCH=${TREE[*]: -1}
    if [[ "${BRANCH}" == "${LAST_BRANCH}__"* ]] ; then
      TREE+=("${BRANCH}")
      PARENT_BRANCH="${LAST_BRANCH}"
    else
      unset 'TREE[${#TREE[@]}-1]'
      set_parent_branch "${BRANCH}"
    fi
  fi
}

# --------------------------------------
# spacers
#
# build spacers for displaying branches
# hierarchically eg. the "|   " in:
# |   branch_a
# |   +-- branch_a_b
# |   |   +-- branch_a_b_c
# --------------------------------------

build_dir_spacers () {
  local OUTPUT=""
  for (( i=1 ; i<${#TREE[*]} ; i++ )) ; do
    OUTPUT+="${DIR_SPACER} "
  done
  echo -e "${OUTPUT}"
}

# --------------------------------------
# print hierarchy
#
# print branches hierarchically eg.
# |   branch_a
# |   +-- branch_a_b
# |   |   +-- branch_a_b_c
# --------------------------------------

print_hierarchy_item_branch () {
  local BRANCH="${1}"
  local BRANCH_STATUS="${2}"
  local IS_VERBOSE="${3}"

  # ... parent branch
  if [[ "${BRANCH}" != "${ROOT_BRANCH}" ]] ; then
    set_parent_branch "${BRANCH}"
  fi

  local DIR="${DIR_SYMBOL}"

  # ... dir spacer
  if [[ "${BRANCH}" != "${ROOT_BRANCH}" ]] ; then
    local DIR_SPACERS=$(build_dir_spacers)
    DIR="${DIR_SPACERS}${DIR_SYMBOL}"
  fi

  DIR="${4:-$DIR}"

  # ... color
  local COLOR="${WHITE}"

  # abbreviate if not verbose
  if [[ $IS_VERBOSE == 0 ]] ; then
    BRANCH="${BRANCH/$PARENT_BRANCH/}"
    BRANCH="${BRANCH/iso__/}"
  fi

  if [[ "${BRANCH_STATUS}" == "${BRANCH_STATUS_NO_REMOTE}" ]] ; then
    COLOR=$LIGHT_GREY
    print "${DIR}" LIGHT_GREY; print "${BRANCH}" COLOR;
  fi

  if [[ "${BRANCH_STATUS}" == "${BRANCH_STATUS_REMOTE}" ]] ; then
    COLOR=$WHITE
    print "${DIR}" LIGHT_GREY; print "${BRANCH}" COLOR;
  fi

  if [[ "${BRANCH_STATUS}" == "${BRANCH_STATUS_CURRENT}" ]] ; then
    COLOR=$LIME
    h2 "${DIR}" COLOR; h2 " ${BRANCH}" COLOR;
  fi
}

print_hierarchy_item () {
  IFS=':' read -ra DATA_ARR <<< "${1}"
  local IS_VERBOSE="${2}"
  local DIR="${3}"

  local BRANCH="${DATA_ARR[0]}"
  local LOCAL="${DATA_ARR[1]}"
  local REMOTE="${DATA_ARR[2]}"

  local BRANCH_STATUS="${BRANCH_STATUS_REMOTE}"
  local DIFF=""
  local DIFF_COLOR=$LIME

  # ... no remote
  if [[ -z "${REMOTE}" ]] ; then
    BRANCH_STATUS="${BRANCH_STATUS_NO_REMOTE}"

  # ... has remote
  else
    BRANCH_STATUS="${BRANCH_STATUS_REMOTE}"
    DIFF=$(get_local_remote_diff "${LOCAL}" "${REMOTE}")
    if [[ $DIFF -gt 0 ]] ; then
      DIFF="+${DIFF}"
      DIFF_COLOR=$LIME
    elif [[ $DIFF -lt 0 ]] ; then
      DIFF_COLOR=$LIGHTRED
    else
      DIFF=""
    fi
  fi

  # ... is current
  if [[ "${BRANCH}" == "${CURRENT_BRANCH}" ]] ; then
    BRANCH_STATUS="${BRANCH_STATUS_CURRENT}"
  fi

  # ... print
  print_hierarchy_item_branch "${BRANCH}" $BRANCH_STATUS $IS_VERBOSE $DIR; print "${DIFF}" DIFF_COLOR ; echo ""
}

print_hierarchy () {

  # ... args

  local args=( )

  for x; do
    case "$x" in
      --fetch|-f)       args+=( -f ) ;;
      --not-verbose|-v) args+=( -v ) ;;
      *)                args+=( "$x" ) ;;
    esac
  done

  set -- "${args[@]}"

  local SHOULD_FETCH=0
  local IS_VERBOSE=1

  unset OPTIND
  while getopts ":fv" x; do
    case "$x" in
      f)  SHOULD_FETCH=1 ;;
      v)  IS_VERBOSE=0 ;;
    esac
  done

  local BRANCH=""

  if [[ "${SHOULD_FETCH}" -eq "1" ]]; then
    git fetch --all
  fi

  # ... Isolation branches

  h1 "Isolation Branches"; echo "" ; echo ""

  # ROOT branch
  for ROOT_DATA in $(git for-each-ref refs/heads --format='%(refname:lstrip=2):%(refname:short):%(upstream:short)' | grep "${ROOT_BRANCH}"); do
    print_hierarchy_item "${ROOT_DATA}" $IS_VERBOSE
  done

  # other branches
  for DATA in $(git for-each-ref refs/heads --format='%(refname:lstrip=2):%(refname:short):%(upstream:short)' | grep '^iso__'); do
    IFS=':' read -ra DATA_ARR <<< "${DATA}"
    local BRANCH="${DATA_ARR[0]}"
    if [[ "${BRANCH}" != "${ROOT_BRANCH}" ]] ; then
      print_hierarchy_item "${DATA}" $IS_VERBOSE
    fi
  done

  echo ""

  # ... Integration branches

  h1 "Integration Branches"; echo "" ; echo ""

  for DATA in $(git for-each-ref refs/heads --format='%(refname:lstrip=2):%(refname:short):%(upstream:short)' | grep '^int__'); do
    print_hierarchy_item "${DATA}" $IS_VERBOSE " -"
  done

  echo ""
}

# --------------------------------------
# strip prefixes
# --------------------------------------

strip_prefix_isolation_branch () {
  echo "${1}" | sed -e 's/^iso__//'
}

strip_prefix_integration_branch () {
  echo "${1}" | sed -e 's/^int__//'
}

strip_prefix_package_branch () {
  echo "${1}" | sed -e 's/^pkg__//'
}


# --------------------------------------
# cascade merge
#
#  - merge parent into child for
#    all Isolation/Package branches
#  - merge all component Isolation branches
#    into all Integration branches
# --------------------------------------

cascade_merge_prechecks () {
  if ! git diff-index --quiet HEAD -- ; then
    echo "Please commit your changes or stash them before you run cascade merge"
    exit 1
  fi
}

cascade_merge_log_failure () {
  local BRANCH=$1
  local MERGE_BRANCH=$2
  local ERROR_TYPE=$3
  local ERROR_MSG=""
  local DATETIME=`date -u "+%Y-%m-%dT%H:%M:%SZ"`
  if [[ -n "${ERROR_LOG_PATH}" ]] ; then
    if [[ "${ERROR_TYPE}" -eq "CONFLICTS" ]] ; then
      ERROR_MSG="git checkout ${BRANCH} && git merge ${MERGE_BRANCH}"
    fi
    echo "${DATETIME} :: ${ERROR_TYPE} :: ${ERROR_MSG}" >> "${PWD}/${ERROR_LOG_PATH}"
  fi
}

cascade_merge_print_failure () {
  local BRANCH=$1
  local MERGE_BRANCH=$2
  local DIR=$3
  local ERROR_TYPE="${4:-FAILURE}"
  print "${DIR} ${BRANCH} < ${MERGE_BRANCH}   * ${ERROR_TYPE}" LIGHTRED ; echo ""
}

cascade_merge_print_success () {
  local BRANCH=$1
  local MERGE_BRANCH=$2
  local DIR=$3
  print "${DIR} ${BRANCH} < ${MERGE_BRANCH}" WHITE ; echo ""
}

cascade_merge_branch () {
  local BRANCH=$1
  local MERGE_BRANCH=$2
  local DIR_SYMBOL2="${3:-$DIR_SYMBOL}"

  # ... checkout branch and merge in parent
  git checkout "${BRANCH}" -q
  git merge "${MERGE_BRANCH}" > /dev/null
  # TODO: distinguish between merge that did something and a merge that did nothing

  # ... check for conflicts
  CONFLICTS=$(git ls-files -u | wc -l | tr -dc '0-9')

  # ... build report and abort if conflicts and log to file
  local DIR_SPACERS=$(build_dir_spacers)
  local DIR_SPACERS2="${4:-$DIR_SPACERS}"
  local DIR="${DIR_SPACERS2}${DIR_SYMBOL2}"
  if [[ "$CONFLICTS" -gt 0 ]] ; then
    git merge --abort
    cascade_merge_log_failure "${BRANCH}" "${MERGE_BRANCH}" "CONFLICTS"
    cascade_merge_print_failure "${BRANCH}" "${MERGE_BRANCH}" "${DIR}" "CONFLICTS"
  else
    cascade_merge_print_success "${BRANCH}" "${MERGE_BRANCH}" "${DIR}"
  fi
}

cascade_merge_isolation_branch () {
  local BRANCH=$1

  # ... figure out and set parent branch
  # ... then merge parent into child
  set_parent_branch "${BRANCH}"
  cascade_merge_branch "${BRANCH}" "${PARENT_BRANCH}"
}

cascade_merge_integration_branch () {
  INTEGRATION_BRANCH="${1}"

  # ... get branches that make up integration branch
  BRANCHES_STR=$(strip_prefix_integration_branch "${1}")
  BRANCH_SEP='--'
  IFS=' ' read -r -a BRANCHES <<< $(printf '%s\n' "${BRANCHES_STR//$BRANCH_SEP/$' '}")
  for BRANCH in "${BRANCHES[@]}"; do
    cascade_merge_branch "${INTEGRATION_BRANCH}" "iso__${BRANCH}" " -" " "
    # TODO: if we want to allow composing of Integration branches then they need different naming and change the above
  done
}

cascade_merge_feature_branch () {
  local BRANCH=$1

  # ... figure out and set parent branch
  # ... then merge parent into child
  set_parent_branch "${BRANCH}"
  cascade_merge_branch "${BRANCH}" "${PARENT_BRANCH}"
}

# TODO: update to return ahead and behind (to indicate diverge)
get_local_remote_diff () {
  local LOCAL="${1}"
  local REMOTE="${2}"

  git rev-list --left-right ${LOCAL}...${REMOTE} -- 2>/dev/null >/tmp/git_upstream_status_delta
  LEFT_AHEAD=$(grep -c '^<' /tmp/git_upstream_status_delta)
  RIGHT_AHEAD=$(grep -c '^>' /tmp/git_upstream_status_delta)

  if [[ "$LEFT_AHEAD" -gt 0 ]] ; then
    echo "${LEFT_AHEAD}"
  elif [[ "$RIGHT_AHEAD" -gt 0 ]] ; then
    echo "-${RIGHT_AHEAD}"
  else
    echo 0
  fi
}

cascade_merge () {
  # ... args
  local args=( )

  for x; do
    case "$x" in
      --from|-f)     args+=( -f ) ;;
      *)             args+=( "$x" ) ;;
    esac
  done

  set -- "${args[@]}"

  local FROM_BRANCH=$ROOT_BRANCH

  unset OPTIND
  while getopts ":f:" x; do
    case "$x" in
      f)  FROM_BRANCH="${OPTARG}" ;;
    esac
  done

  # ... validate from branch
  if [[ "${FROM_BRANCH}" != "${ROOT_BRANCH}" ]] && [[ "${FROM_BRANCH}" != "iso__"* ]] ; then
    echo "Please provide a valid from branch -f or --from (only iso__ branches are supported)"
    exit 1
  fi

  # ...
  cascade_merge_prechecks

  # ... checkout from branch
  git checkout "${FROM_BRANCH}" -q

  # ... cascade merge Isolation branches (optionally from a specfic branch)

  h1 "Isolation Branches"; echo "" ; echo ""

  if [[ "${FROM_BRANCH}" == "${ROOT_BRANCH}" ]] || [[ "${FROM_BRANCH}" == "iso__"* ]] ; then

    local ISO_GREP="^iso__"
    if [[ "${FROM_BRANCH}" != "${ROOT_BRANCH}" ]] ; then
      ISO_GREP="${FROM_BRANCH}__"
    fi

    echo -e "${DIR_SYMBOL} ${FROM_BRANCH}"
    local ISO_BRANCHES=$(git for-each-ref refs/heads --format='%(refname:lstrip=2)' | grep "${ISO_GREP}")

    for BRANCH in $ISO_BRANCHES; do
      if [[ "${BRANCH}" != "${ROOT_BRANCH}" ]] ; then
        cascade_merge_isolation_branch "${BRANCH}"
      fi
    done
    echo ""
  fi

  # ... cascade merge Integration branches (only from root)

  if [[ "${FROM_BRANCH}" == "${ROOT_BRANCH}" ]] ; then

    h1 "Integration Branches"; echo "" ; echo ""

    local INT_BRANCHES=$(git for-each-ref refs/heads --format='%(refname:lstrip=2)' | grep '^int__')

    for BRANCH in $INT_BRANCHES; do
      cascade_merge_integration_branch "${BRANCH}"
    done
    echo ""
  fi

  # ... re-checkout current branch
  git checkout "${CURRENT_BRANCH}" -q
}

# --------------------------------------
# build_integration_branch
# $1 BRANCH
#
# creates a new branch of the provided name
# and merges all required branches into it
# --------------------------------------

build_integration_branch () {
  BRANCH=$1

  h1 "Building Integration Branch"; echo "" ; h2 "${BRANCH}" ; echo "" ; echo ""

  git checkout -b "${BRANCH}"
  cascade_merge_integration_branch "${BRANCH}"
}

# --------------------------------------
# hack CLI
# --------------------------------------

$@
