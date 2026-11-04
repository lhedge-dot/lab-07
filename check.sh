#!/bin/bash
# Source: Claude (Anthropic), generated 2026-11-04
# Checks the output that script.sh made. For every Testcase folder, each .1/.2 pair that
# differs must have a matching file in TestcaseNDiff/, and each identical pair must have none.
# If nothing differs in a Testcase, TestcaseNDiff/ must not exist at all.
# Prints one PASS or FAIL line per Testcase. Exits 0 only if every Testcase passes.

status=0

for dir in Testcase*; do
    # Skip anything that is not a folder, and skip the output folders (TestcaseNDiff).
    [ -d "$dir" ] || continue
    case "$dir" in *Diff) continue ;; esac

    num=${dir#Testcase}
    outdir="Testcase${num}Diff"
    ok=1
    diffs=0

    for first in "$dir"/*.1.txt; do
        [ -f "$first" ] || continue
        second="${first%.1.txt}.2.txt"
        [ -f "$second" ] || continue

        name=$(basename "${first%.1.txt}")
        result="$outdir/${name}Diff.txt"

        if cmp -s "$first" "$second"; then
            # Identical pair, so there must be no output file for it.
            if [ -e "$result" ]; then
                # Source: CMPUT 201 Lecture 5 (File I/O and Program Arguments), Henry Tang, slide 9.
                # Referenced for sending error messages to stderr, here with >&2.
                echo "  $result should not exist because the pair is identical" >&2
                ok=0
            fi
        else
            diffs=$((diffs + 1))
            # Different pair, so the output file must exist and match diff -u.
            if [ ! -f "$result" ]; then
                echo "  $result is missing" >&2
                ok=0
            else
                # tail -n +3 skips the two header lines (file names and timestamps).
                if ! cmp -s <(diff -u "$first" "$second" | tail -n +3) <(tail -n +3 "$result"); then
                    echo "  $result does not match diff -u" >&2
                    ok=0
                fi
            fi
        fi
    done

    # If no pair differs, the output folder should not exist at all, even if it is empty.
    if [ "$diffs" -eq 0 ] && [ -e "$outdir" ]; then
        echo "  $outdir should not exist because nothing differs" >&2
        ok=0
    fi

    # Every file in the output folder must belong to a pair that really differs.
    if [ -d "$outdir" ]; then
        for file in "$outdir"/*; do
            [ -e "$file" ] || continue
            base=$(basename "$file")
            name=${base%Diff.txt}
            if [ "$name" = "$base" ] || [ ! -f "$dir/$name.1.txt" ] || [ ! -f "$dir/$name.2.txt" ] \
                || cmp -s "$dir/$name.1.txt" "$dir/$name.2.txt"; then
                echo "  $file should not exist" >&2
                ok=0
            fi
        done
    fi

    if [ "$ok" -eq 1 ]; then
        echo "Testcase${num}: PASS"
    else
        echo "Testcase${num}: FAIL"
        status=1
    fi
done

# Source: CMPUT 201 Lecture 12 (Functions), Henry Tang, slide 20.
# Referenced for a status code of 0 meaning success and non-zero meaning failure.
exit "$status"
