gitrepo_updater
===============

Clones and keeps updated local (git) repos.

Installation
------------
~~~~
bundle install
bundle exec rackup -p <your desired port>
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

the latter command, clones `https://github.com/lsandoval/test` (origin) on `/Users/leonardo/Devel` and indicates
github_updater to be aware of any changes origin so it automatically upadtes (git pull)
