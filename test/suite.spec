#!/usr/bin/env zsh
#vim:ft=zsh ts=2 sw=2 sts=2 et fenc=utf-8

local failed=false

for test in **/*.spec; do
    echo
    echo "Now executing ${test}"
    if [[ "${test}" == "test/suite.spec" ]]; then
        continue;
    fi
    ./${test} || failed=true
done

if [[ "${failed}" == "true" ]]; then
    exit 1
fi