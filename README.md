Reviewlette
===========

[![Coverage Status](https://img.shields.io/coveralls/jschmid1/reviewlette.svg)](https://coveralls.io/r/jschmid1/reviewlette)
[![Code Climate](https://codeclimate.com/github/jschmid1/reviewlette.png)](https://codeclimate.com/github/jschmid1/reviewlette)

Tool to automatically assign a "Reviewer" to a GitHub Issue and to the attached Trello Card.


What it does:

- Finds unassigned issues on GitHub.
- Assigns a member of your team.
- Locates the right Card on Trello.
- Checks if the assignee is on vacation(using tel).
- Adds the assigned member to the Card.
- Move the card to 'In review'


## Installation

```
gem install reviewlette
reviewlette
```


## Setup

#### Name your pullrequest like so:
#### Review_#23_name_of_review_42  <= trello card number

Fill `config/.trello.yml` (instructions in the file)
Fill `config/.github.yml` (instructions in the file


---

[Using Octokit as a GitHub api wrapper](https://github.com/octokit/octokit.rb)
[Using ruby-trello as a Trello api wrapper](https://github.com/jeremytregunna/ruby-trello)



