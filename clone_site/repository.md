# repository.bash

## Requirements

- git
- subversion

## Settings


## Arguments

- `-h | --help` - help info
- `-U | --user` - clone/checkout folder owner
- `-t | --type` - repository type [ `svn` or `git`]
- `-u | --url` - repository address [ example: `https://github.com/reyzeer/bashscripts.git` ]
- `-d | --dir` - here, repository is clone/checkout. [ example: `~/my_repositories` ]

## Example

`bash repository.bash -U reyzeer -d /home/reyzeer/repos -t git -u https://github.com/reyzeer/bashscripts.git`

## Return

`null`
