#!/usr/bin/env bash

# usage: template file.tpl
template(){
    while read -r line ; do
		 line=${line//\\/\\\\}
        line=${line//\"/\\\"}
        line=${line//\`/\\\`}
        line=${line//\$/\\\$}
        line=${line//\\\${/\${}
        eval "echo \"$line\""; 
    done < ${1}
}
