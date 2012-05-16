gitrepo_updater
===============

Clones and keeps updated local (git) repos.

Installation
------------
~~~~
$ bundle install # 1. install gems
$ vi config.ru # 2. modify the config.ru if needed
$ bundle exec rackup -p <your desired port> # 3. Start the server
~~~~

Usage
-----

Specify the repo to clone/update

~~~~
$ ./adder --help
Options:
        --github-user-name, -g <s>:   The Github username (default: ooyala)
  --github-repository-name, -i <s>:   The Github repository name (default: )
              --local-path, -l <s>:   The local Github repository path (default: )
             --restart-cmd, -r <s>:   Command line to restart your app (default: )
            --github-login, -t <s>:   The Github login (default: )
         --github-password, -h <s>:   The Github password (default: )
             --github-hook, -u <s>:   The Github hook, which is the name of the current domain (default: )
                        --help, -e:   Show this message
~~~~

For example

~~~~
$ ./adder -g lsandoval \
        -i test \
        -l /home/dev/tmp1 \
        -t lsandoval \
        -h <github pass> \
        -u http://csg-eng.ooyala.com/gitrepo_updater
~~~~

the latter command, clones `https://github.com/lsandoval/test` (origin) on `/home/dev/tmp1` and indicates
the app to be aware of any changes in origin. When a new commit is pushed to origin, the
app automatically updates (`git pull`) and run any restart command if given through the parameter `--restart-cmd`.

Also, to see if the app is updating correctly, this command does a test push to the repo

~~~~
$ ./push_test -g lsandoval \
            -i test \
            -t lsandoval \
            -h <github pass> \
            -u http://csg-eng.ooyala.com/gitrepo_updater
~~~~
