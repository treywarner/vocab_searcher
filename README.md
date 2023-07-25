# Vocab Searcher
search through vocabulary lists

## How to use
give an argument of a vocab file to read.
- this file currently needs to be formatted topic: explanantion etc.

give another argument for the query.
- query is written in regex
- use flag -r to reverse query: search the explanantions rather than the topics, very useful.
or none to enter interactive mode
- basically you don't need to enter the program or file anymore, just flags and prompts

## Output
matches to your query are highlighted in blue
topics that show up in explanantion are highlighted in magenta.

## Flags
- -r reverse queries. look above
- -p gives a plain output
- -d doubles the newlines between each entry

## TODO
- add more regex options
- fix interactive mode (left arrow, up arrow etc)
- add link support
- free formatting of files
