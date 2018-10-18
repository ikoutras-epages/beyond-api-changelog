#!/bin/bash

SCRIPT_DIR="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

usage () {
     cat << EOF
DESCRIPTION:
Updates the given changelog file with a digest of the difference between two OpenAPI spec files.

SYNOPSIS:
$0 -o old_api_spec -n new_api_spec -c change_log

OPTIONS:
    -o   The YAML file with the old version of the API spec.
    -n   The YAML file with the new version of the API spec.
    -c   The ADOC file with the documentation of the API changes.
    -h   Show this message.
    -?   Show this message.
EOF
}

while getopts "o: n: c: h ?" option ; do
     case $option in
          o)   OLD_API_SPEC_FILE="${OPTARG}"
               ;;
          n)   NEW_API_SPEC_FILE="${OPTARG}"
               ;;
          c)   CHANGE_LOG_FILE="${OPTARG}"
               ;;
          h )  usage
               exit 0;;
          ? )  usage
               exit 0;;
     esac
done

if [[ -z ${OLD_API_SPEC_FILE} ]]; then
    echo "ERROR: parameter '-o' not set"
    usage
    exit 1
fi

if [[ -z ${NEW_API_SPEC_FILE} ]]; then
    echo "ERROR: parameter '-n' not set"
    usage
    exit 1
fi

if [[ -z ${CHANGE_LOG_FILE} ]]; then
    echo "ERROR: parameter '-c' not set"
    usage
    exit 1
fi

################################################################################
# Build change log snippet
################################################################################
CURRENT_DATE=$(date '+%Y-%m-%d')
API_DIFF=$(${SCRIPT_DIR}/diff.sh ${OLD_API_SPEC_FILE} ${NEW_API_SPEC_FILE})

CHANGE_LOG=$(cat <<EOF
## ${CURRENT_DATE}

${API_DIFF}
EOF
)

echo -e ${API_DIFF}

################################################################################
# Insert change log
################################################################################
ESCAPED_CHANGE_LOG=$(echo -e "${CHANGE_LOG}" | sed -e 's/[\/&|]/\\&/g')
CHANGE_LOG_PLACEHOLDER="###CHANGE_LOG_HERE###"
sed -i "/# Beyond API Changelog/ a ${CHANGE_LOG_PLACEHOLDER}" ${CHANGE_LOG_FILE}
perl -pi -e "s/${CHANGE_LOG_PLACEHOLDER}/${ESCAPED_CHANGE_LOG}/g" ${CHANGE_LOG_FILE}
