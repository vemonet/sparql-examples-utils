#!/usr/bin/bash

set -o errexit # -e does not work in Shebang-line!
set -o pipefail
set -o nounset

prefixes=$(sparql --results=TSV --data=prefixes.ttl "PREFIX sh:<http://www.w3.org/ns/shacl#> SELECT ?s WHERE {?pn sh:prefix ?prefix ; sh:namespace ?namespaceI . BIND(CONCAT('PREFIX ',?prefix, ':<',(STR(?namespaceI)),'>') AS ?s)}"|grep -v "^\?s$" |tr -d '"')

for i in $(ls */[1-9]*.ttl);
do
    f=$(echo $i | cut -f 2 -d '/' )	
    if [ $(grep -c "ex:${f:0:${#f}-4}" $i) -lt 1 ];
    then 
        echo $i;
        exit 1;
    fi;
    if [ $(rapper -q -i turtle -c $i) ];
    then
	  echo $i;
	  exit 2;
    fi 
    q=$(sparql --results=TSV --data=$i "PREFIX sh:<http://www.w3.org/ns/shacl#> SELECT ?qs WHERE {?q sh:select|sh:describe|sh:construct|sh:ask ?qs}"|grep -vP "^\?qs$");
    pq="${q:1:${#q}-2}";
    if [[ ! -z "$pq" ]]
    then
        query="$prefixes $pq"
        if [[ ! $(echo -e $query | sed 's|\\"|"|g' | sparql --query=/dev/stdin) ]]
        then
            echo $i
            echo -e "__${pq}__"
            exit 3;
        fi
    fi
done
