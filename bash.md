# BASH

## Source directory of scrpt
How to make a bash script know which directory it's located in, rather than just the directory is has been called from.  Useful for when you add a script to your path, but the script needs to access resources which are stored alongside it.

Relevant link: https://stackoverflow.com/questions/59895/getting-the-source-directory-of-a-bash-script-from-within

### The Problem
Suppose you have a script named `quote` stored in `~/.local/bin/` which depends on a resource `data.txt` stored alongside it.

**quote:**

    #!/usr/bin/env bash
    cat data.txt

**data.txt**:

    "The problem is not thoughts themselves but the state of thinking without knowing that we are thinking." - Sam Harris

If the script is executable (`chmod 755 ~/.local/bin/quote`) and on the path (`echo 'export PATH=~/.local/bin:$PATH' >> ~/.profile`)
then you can call it from anywhere.  But it doesn't work:

    $ cd ~/.local/bin && quote
    "The problem is not thoughts themselves but the state of thinking without knowing that we are thinking." - Sam Harris

    $ cd ~ && quote
    cat: data.txt: No such file or directory

### The Solution

    #!/usr/bin/env bash
    
    SOURCE="${BASH_SOURCE[0]}"
    while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
    DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
    SOURCE="$(readlink "$SOURCE")"
    [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
    done
    DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"

    cat $DIR/data.txt

Now you can run the script from anywhere, and it can access resources stored in its source directory using `$DIR`, wherever that directoy may be.