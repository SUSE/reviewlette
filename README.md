Reviewlette
===========

[![Coverage Status](https://img.shields.io/coveralls/jschmid1/reviewlette.svg)](https://coveralls.io/r/jschmid1/reviewlette)
[![Code Climate](https://codeclimate.com/github/jschmid1/reviewlette.png)](https://codeclimate.com/github/jschmid1/reviewlette)

Tool to automatically assign a "Reviewer" to a GitHub Issue and to the attached Trello Card.


What it does:

- Finds unassigned issues on GitHub.
- Assignes a member of your team.
- Locates the right Card on Trello.
- Checks if the assignee is on vacation(using tel).
- Adds the assigned member to the Card.
- If the Issue/PullRequest is closed or merged move it in the right column.
- Prints graphs using Morris.js to display statistics(autorefresh every 5 seconds).


![graphs](http://h.dropcanvas.com/72fj0/graph.jpg, "graphs")


## Installation

```
git clone git@github.com:jschmid1/reviewlette.git
cd reviewlette
bundle
cd bin
./reviewlette
```

or

```
gem install reviewlette
```


## Setup

#### Name your pullrequest like so:
#### Review_#23_name_of_review_42  <= trello card number

```
Fill `config/.trello.yml` with your **consumerkey**, **consumersecret**, **oauthtoken** and **board_id**
```yml
-comsumerkey: theconsumerkey11
-consumersecret: theconsumersecret11
-oauthtoken: theoauthtoken11
```

[Which can be generated here](https://trello.com/1/appKey/generate)

Fill `config/.github.yml` with your **token** and **repo**
```yml
-token: thetokenfromgithub
-repo: my/repo
```

[Which can be generated here](https://github.com/settings/applications/new)


Edit the `reviewlette.db` scaffold in the main directory to your needs.

You can either use a GUI like [Sqlite database browser](http://sqlitebrowser.org/) or the sqlite commandline interface

e.g.

```ruby
insert into employee values('John','Smith', '0', '', 'github_name', 'trello_name', 'tel_name');
```

---

[Using Octokit as a GitHub api wrapper](https://github.com/octokit/octokit.rb)

[Using Sequel as Database Module](https://github.com/jeremyevans/sequel)

[Using ruby-trello as a Trello api wrapper](https://github.com/jeremytregunna/ruby-trello)



