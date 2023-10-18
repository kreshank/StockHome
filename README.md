# CS-3110 Final Project - StockHome
This is a program that pulls stock data from an API for a user to manipulate or track. Using data from the API, a user can build a portfolio, track stock prices, save and write configurations, and more. 
-----------------------------------
## Files and Their Purposes
### Folders 
| Folder | Description |
| ----------- | ----------- |
| bin | holds executable binaries |
| src | holds source code |
| test | holds Ounit tests |

### Files
| File | Description |
| ----------- | ----------- |
| api.ml | contains code relevant to any APIs used to gather data |
| display.ml | contains code for the terminal UI |
| portfolio.ml | contains module for a data structure that holds multiple stock.t data types |
| stock.ml | contains functor that takes a parser module and converts it into a stock.t data type  | 
| parser.ml | contains code that takes data from a .txt file a parses it into a module | 

*More detailed documentation is present within the files themselves.*


## Git Commits
This is the standard Git commit format we will be using to ensure everyone can understand what feature have been added or changed.

```
[Summary]

-[Details (e.g [Added/Changed Features/Functions])]
-[Name and Email]
```

So, an example of this would be:

```
Updated API

- pull_yahoo can now request data from the api and store it in a stock data structure 
- Leo - ll865@cornell.edu
```

## Git Pull and Merge 
Calling `git merge` will automatically merge any changes you have made into the main branch. Try not to change files other people are working on to prevent merges as much as possible.

Calling `git pull` will pull any changes from the main branch, and you may have to merge instead if prompted. Try to pull before you push or when you begin working on the code.

### PLEASE LET EVERYONE KNOW WHAT YOU ARE CHANGING AHEAD OF TIME


## Makefile
The Makefile has several commands that can be used, such as:

- make utop: Builds utop with imported source code (for testing)
- make test: Runs tests in test folder with Ounit2
- make display: Executes display.ml to create a UI in the terminal for testing and demonstration purposes
- make build - Calls dune build

## Project Members 
- Ryan Wu rw645@cornell.edu 
- Leo Lu ll865@cornell.edu 
- Bodong Liu bl576@cornell.edu 
- Bhuwan Bhattarai bb623@cornell.edu 
