#!/usr/bin/env bash

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

DIR_SYMBOL=" +--"
DIR_SPACER=" |  "
ROOT_BRANCH="${ROOT_BRANCH:-master}"

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
  for (( i=2 ; i<${#TREE[*]} ; i++ )) ; do
    OUTPUT+="${DIR_SPACER}"
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

print_hierarchy_branch () {
  local BRANCH="${1}"
  set_parent_branch "${BRANCH}"
  local DIR_SPACERS=$(build_dir_spacers)
  local DIR="${DIR_SPACERS}${DIR_SYMBOL}"
  DIR="${2:-$DIR}"
  echo -e "${DIR} ${BRANCH}"
}

print_hierarchy () {
  local BRANCH=""

  echo -e "Isolation Branches\n----------------------"
  for BRANCH in $(ls .git/refs/heads | grep '^iso__') ; do
    print_hierarchy_branch "${BRANCH}"
  done
  echo ""

  echo -e "Integration Branches\n----------------------"
  for BRANCH in $(ls .git/refs/heads | grep '^int__') ; do
    print_hierarchy_branch "${BRANCH}" " -"
  done
  echo ""

  echo -e "Feature Branches\n----------------------"
  for BRANCH in $(ls .git/refs/heads | grep '^feat__') ; do
    print_hierarchy_branch "${BRANCH}"
  done
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

strip_prefix_feature_branch () {
  echo "${1}" | sed -e 's/^feat__//'
}


# --------------------------------------
# cascade merge
#
#  - merge parent into child for
#    all Isolation/Feature branches
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
  echo "${DIR} ${BRANCH} < ${MERGE_BRANCH}   * ${ERROR_TYPE}"
}

cascade_merge_print_success () {
  local BRANCH=$1
  local MERGE_BRANCH=$2
  local DIR=$3
  echo "${DIR} ${BRANCH} < ${MERGE_BRANCH}"
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

cascade_merge () {
  cascade_merge_prechecks

  # ... checkout root branch
  git checkout "${ROOT_BRANCH}" -q

  # ... cascade merge Isolation branches
  echo -e "Isolation Branches\n----------------------"
  for BRANCH in $(ls .git/refs/heads | grep '^iso__') ; do
    cascade_merge_isolation_branch "${BRANCH}"
  done
  echo ""

  # ... cascade merge Integration branches
  echo -e "Integration Branches\n----------------------"
  for BRANCH in $(ls .git/refs/heads | grep '^int__') ; do
    cascade_merge_integration_branch "${BRANCH}"
  done
  echo ""

  # ... cascade merge Feature branches
  echo -e "Feature Branches\n----------------------"
  for BRANCH in $(ls .git/refs/heads | grep '^feat__') ; do
    cascade_merge_feature_branch "${BRANCH}"
  done
  echo ""

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

  echo -e "Building Integration Branch\n${BRANCH}\n----------------------"
  git checkout -b "${BRANCH}"
  cascade_merge_integration_branch "${BRANCH}"
}

# --------------------------------------
# hack CLI
# --------------------------------------

$@
