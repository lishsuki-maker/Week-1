Bug #1

Prediction
It is predicted that setting the permissions to 644 could cause an issue when executing the script because execute permission is not granted to the owner, group, or other users.

Run
Directly executing the script with ./rotate_logs.sh resulted in -bash: ./rotate_logs.sh: Permission denied, confirming that the prediction was correct.

Fix
Set the permissions to 755 so that the script can be executed by the owner, group, and other users via chmod 755 rotate_logs.sh.


Bug #2

Prediction
It is predicted that the absence of set -euo pipefail could lead to the script silently misbehaving as described because it may continue running even when errors occur early in the script.

Run
Directly executing the script with ./rotate_logs.sh resulted in the following error messages:
./rotate_logs.sh: line 4: syntax error near unexpected token 'do'
./rotate_logs.sh: line 4: 'log_dir=$2for f in $(ls $log_dir/* .log); do'

Although the prediction could not be confirmed because the script automatically stopped after a syntax error was detected, the test was re-run after the syntax errors were fixed, as described in Bug #3.

After applying the fixes, executing the script resulted in the following output:
ls: cannot access '/* .log': No such file or directory
Archived files

Because the Archived files output was still produced even though the ls command returned an error, this confirmed that the prediction was correct.

Fix
Add set -euo pipefail after #!/usr/bin/env bash.


Bug #3

Prediction
The error messages from Bug #2 demonstrated that a syntax error occurred on line 4, where the for ...; do statement was not properly separated from the log_dir=$2 statement. However, apart from that, it was predicted that additional syntax errors existed. These included the if ...; then statement not being properly separated from the age=$(find $f -mtime +7) command and the mv $f $archive_dir/ command, as well as the fi, done, and echo "Archived $counf files" statements not being properly separated from one another.

Run
Running bash -n rotate_logs.sh initially resulted in the same error messages as described in Bug #2. Although the predictions regarding the other syntax errors could not yet be confirmed, the test was re-run after each syntax error was fixed.

After applying Fix 3.1, running bash -n rotate_logs.sh resulted in rotate_logs.sh: line 8: syntax error: unexpected end of file.This appeared to suggest that additional syntax errors might remain in the later part of the script.

After applying Fix 3.2, running bash -n rotate_logs.sh still resulted in a similar error message, appearing to suggest that the remaining fi, done, and echo "Archived $count files" statements might still need to be properly separated.

After applying Fix 3.3, running bash -n rotate_logs.sh produced no output, confirming that the predictions were correct and that the syntax errors had been fixed.

Fix 3.1
Place the for ...; do statement on a new line.

Fix 3.2
Place the if ...; then statement and the mv $f $archive_dir/ command on separate lines.

Fix 3.3
Place the fi, done, and echo "Archived $count files" statements on separate lines.


Bug #4

Prediction
It is predicted that the use of the count=$count+1 could result in a final output that does not make sense as described because it would not perform any arithmetic operations.

Run
Running bash -x rotate_logs.sh archive log resulted in the error rotate_logs.sh: line 13: count: unbound variable. Although this was not part of the initial prediction, the result suggested that the count variable had not been assigned a value before being used. The test was re-run after this error was fixed.

After applying Fix 4.1, running bash -x rotate_logs.sh archive log resulted in Archived 0 files. This appeared to suggest that the initial prediction was not observed under this test condition.

However, because the script was intended to archive .log files older than 7 days, the test was re-run with a .log file whose modification time was set to more than 7 days ago. The output Archived 0+1 files confirmed that the prediction was correct.

Fix 4.1
Add count=0 after assigning values to the archive_dir and log_dir variables.

Fix 4.2
Replace count=$count+1 with count=$((count+1)) to perform arithmetic addition correctly.


Bug #5

Prediction
Because of the absence of double quotation marks around certain variables, it is predicted that files with filenames containing spaces might not be processed because the values of those variables could be split into multiple arguments.

Run
Running bash -x rotate_logs.sh archive log with a .log file whose filename contained a space and whose modification time was set to more than 7 days ago resulted in find: ‘log/test’: No such file or directory, confirming that the prediction was correct.

In addition, running shellcheck rotate_logs.sh resulted in the following output:
In rotate_logs.sh line 8:
for f in $(ls $log_dir/* .log); do
         ^------------------^ SC2045 (error): Iterating over ls output is fragile. Use globs.
              ^------^ SC2086 (info): Double quote to prevent globbing and word splitting.

Did you mean:
for f in $(ls "$log_dir"/* .log); do


In rotate_logs.sh line 9:
age=$(find $f -mtime +7)
           ^-- SC2086 (info): Double quote to prevent globbing and word splitting.

Did you mean:
age=$(find "$f" -mtime +7)


In rotate_logs.sh line 10:
if [ $age ]; then
     ^--^ SC2086 (info): Double quote to prevent globbing and word splitting.

Did you mean:
if [ "$age" ]; then


In rotate_logs.sh line 11:
        mv $f $archive_dir/
           ^-- SC2086 (info): Double quote to prevent globbing and word splitting.
              ^----------^ SC2086 (info): Double quote to prevent globbing and word splitting.

Did you mean:
        mv "$f" "$archive_dir"/

As shown above, the test demonstrated that double quotation marks were needed around the affected variables to prevent globbing and word splitting, which was consistent with the prediction. The test also identified an additional issue with iterating over ls output, which is addressed separately in Bug #6.

Fix
Enclose the affected variables in double quotation marks, as recommended by ShellCheck, to prevent globbing and word splitting.


Bug #6

Prediction
Considering the findings from Bug #5, which indicated that using the output of the ls command is unreliable, it is predicted that certain files might still not be processed, which could in turn result in files not being archived or errors being encountered, as described.

Run
Running bash -x rotate_logs.sh archive log with a .log file whose filename contained a space and whose modification time was set to more than 7 days ago resulted in find: ‘log/test’: No such file or directory. This confirmed that the prediction was correct.

Fix
Replace for f in $(ls "$log_dir"/* .log); do with for f in "$log_dir"/* .log; do


Bug #7

Prediction
It is predicted that an issue could occur when executing the script without supplying the directories as arguments because the archive_dir and log_dir variables would not have any values assigned to them.

Run
Directly executing the script with ./rotate_logs.sh resulted in ./rotate_logs.sh: line 4: $1: unbound variable. The result clearly indicated that the archive_dir variable had not been assigned a value before being used, confirming that the prediction was correct.

Furthermore, executing the script with ./rotate_logs.sh archive log produced Archived 1 files, further confirming that the required directory arguments were needed for the script to execute successfully.

Fix
As required by the acceptance criteria, add the following argument validation after set -euo pipefail so that if two arguments are not supplied, a descriptive usage message is provided and the script exits with a non-zero status:
if [ "$#" -ne 2 ]; then
echo "Usage: $0 <archive_dir> <log_dir>" >&2
exit 1
fi
