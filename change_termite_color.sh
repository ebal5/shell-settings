#! /bin/bash

dname=base16-termite/themes/
theme=$(ls $dname | fzf)
cat termite_config_base $dname$theme | sed 's/\(background.*rgba(\)\(.*\))/\1\2, 0.8)/' > home/.config/termite/config

