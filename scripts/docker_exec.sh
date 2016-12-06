#!/bin/bash

SRC_DIR=$(cd $(dirname $0)/../ && pwd)
SCRIPT_NAME="$(basename \"$(test -L \"$0\" && readlink \"$0\" || echo \"$0\")\")"
ENTRY_POINT="/tmp/dock_fgap_run_entry_point.sh"
: ${QT_VERSION:="qt:5.7.0"}

cat > ${ENTRY_POINT} << EOF
#!/bin/bash
groupadd -g $(getent group $USER | cut -d: -f3) $USER
useradd -g $USER -G sudo -N -u $UID $USER
/bin/su $USER -c "env && cd $PWD && ls -lah && echo \"Building with: $(qmake --version) ($(which qmake))\" && $@"

EOF
chmod +x ${ENTRY_POINT}

VOLUMES="-v ${ENTRY_POINT}:${ENTRY_POINT}:ro"
VOLUMES="${VOLUMES} -v $PWD:$PWD"

docker run --rm --entrypoint=${ENTRY_POINT} ${VOLUMES}  approximator/$QT_VERSION
rm ${ENTRY_POINT}