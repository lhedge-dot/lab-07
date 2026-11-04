#!/bin/bash
# Compares every .1/.2 file pair in each Testcase folder with diff -u. The result of
# each pair that differs is saved in TestcaseNDiff/ as <pair name>Diff.txt.

# This removes the old output folders first so the script gives the same result on every run.
rm -rf Testcase*Diff

for dir in Testcase*; do
    # This skipss anything that is not a folder.
    [ -d "$dir" ] || continue
    # The Testcase number is whatever comes after "Testcase" in the folder name.
    num=${dir#Testcase}

    for first in "$dir"/*.1.txt; do
        # Skip if the pattern matched no files.
        [ -f "$first" ] || continue
        # The partner file has the same name with .2.txt in place of .1.txt.
        second="${first%.1.txt}.2.txt"
        [ -f "$second" ] || continue

        # Pair name without the folder or the .1.txt, for example Version3.
        name=$(basename "${first%.1.txt}")

        # Only pairs that differ get an output file, and the folder is made when needed.
        if ! cmp -s "$first" "$second"; then
            mkdir -p "Testcase${num}Diff"
            # Source: CMPUT 201 Lecture 5 the File I/O and Program Arguments, Henry Tang, slide 8.
            # Referenced for using > to send a program's output into a file instead of the screen.
            diff -u "$first" "$second" > "Testcase${num}Diff/${name}Diff.txt"
        fi
    done
done
