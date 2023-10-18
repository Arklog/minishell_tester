#!/bin/bash

MINISHELL=../minishell
VALGRIND="valgrind --leak-check=full --error-exitcode=1 "

TESTSDIR=tests
TESTS="$(ls $TESTSDIR)"

COMMAND=commands
OUTPUT=output.log
EXPECTED=expected

#resolving minishell binary path
MINISHELL="$(realpath $MINISHELL)"
if [[ $MINISHELL ]]; then
    echo $MINISHELL
    echo "minishell binary not found"
    exit 1
fi

function valgrind_check()
{
    EXITCODE=0

    $VALGRIND $MINISHELL <$COMMAND >$OUTPUT
    return $?
}

function output_check()
{
    DIFF="$(diff $EXPECTED $OUTPUT)"
    
    if [[ $DIFF ]]; then
        return 1
    else
        return 0
    fi
}

function run_test()
{
    TESTNUMBER=$1
    EXITCODE=0

    echo "Checking: $TESTNUMBER"
    valgrind_check
    EXITCODE=$?
    if [[ $EXITCODE == 0 ]]; then
        echo "VALGRIND: OK"
    else
        echo "VALGRIND: KO"
    fi
    output_check
    EXITCODE=$?
    if [[ $EXITCODE == 0 ]]; then
        echo "OUTPUT: OK"
    else
        echo "OUTPUT: KO"
    fi
}

#cleaning leftover files from previous runs
echo "Cleaning"
for i in $TESTS; do
    rm -f "$TESTSDIR/$TESTS/output.log"
done

#executing tests
echo "Testing"
for i in $TESTS; do
    cd "$TESTSDIR/$i" >/dev/null || exit
    cd - >/dev/null || exit
done