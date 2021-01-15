#!/bin/bash

function usage()
{
    echo "setup.sh DIRECTORY [viewer]"
}

# get directory to target
if [[ $# -eq 0 ]]; then
    usage
    echo "Directory is required"
    exit
fi

target=$1
if [[ ! -d $target ]]; then
    usage
    echo "Directory must exist, $target does not"
    exit
fi

# add full path and remove trailing `/` from current file
awk_script=$PWD/${0%/*}/parse_exercise.awk
cd $target

# get dir basename
name=${target%/}
setup_script=$name/setup_files.sh
name=${name##*/}

# set viewer if provided
if [[ $# -eq 2 ]]; then
    viewer=$2
    if ! command -v $viewer &> /dev/null ; then
        echo "Cannot find command $viewer, using default, less"
        viewer=less
    fi
else
    viewer=less
fi

# run setup script in target
echo Starting setup
mkdir -p /tmp/$USER/210119-ACL/$name
cd /tmp/$USER/210119-ACL/$name
$setup_script

# setup new session with view of readme
echo Creating session
tmux new-session \
    -s $name \
    -n README \
    -d \
    "$viewer README.md"

# parse out exercises into separate windows with a split pane
ex_num=1
while true ; do
    # if awk produces no output, exit loop
    if [[ -z $(awk -f $awk_script -v target=$ex_num README.md) ]] ; then
        break
    fi
    # capture command to start tmux window with
    cmd="awk -f $awk_script -v target=$ex_num README.md | $viewer -"
    tmux new-window \
        -n "Exercise $ex_num" \
        "$cmd" \; \
    split-window -h \; \
    send-keys "cd files " C-m
    ex_num=$(($ex_num + 1))
done

# Select first window
tmux select-window -t ^

# change to original directory, no printout
cd - > /dev/null

echo tmux session $name created with $ex_num exercises
