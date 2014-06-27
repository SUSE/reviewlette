Reviewlette
===========

[![Coverage Status](https://img.shields.io/coveralls/jschmid1/reviewlette.svg)](https://coveralls.io/r/jschmid1/reviewlette)
[![Code Climate](https://codeclimate.com/github/jschmid1/reviewlette.png)](https://codeclimate.com/github/jschmid1/reviewlette)

Tool to automatically assign a "Reviewer" to a GitHub Issue and to the attached Trello Card.


What it does:

- Finds unassigned issues on GitHub
- Assignes a member of your team
- Locates the right Card on Trello
- Adds the assigned member to the Card
- If the Issue/PullRequest is closed or merged move it in the right column
- Sends a notification mail

## Setup

#### Name your pullrequest like so:
#### Review_#23_name_of_review_42  <= trello card number

Fill `config/.members.yml` with the *trellonames* as key and the *githubname* as value.
```yml
-trelloname: 'githubame'
-another_name: 'corresponding_github_name'
```
Fill `config/.trello.yml` with your *consumerkey*, *consumersecret*, *oauthtoken* and *board_id*
```yml
-comsumerkey: theconsumerkey11
-consumersecret: theconsumersecret11
-oauthtoken: theoauthtoken11
```

[Which can be generated here](https://trello.com/1/appKey/generate)

Fill `config/.github.yml` with your *token* 
```yml
-token: thetokenfromgithub
```

[Which can be generated here](https://github.com/settings/applications/new)


---

[Using Octokit as a GitHub api wrapper](https://github.com/octokit/octokit.rb)

[Using ruby-trello as a Trello api wrapper](https://github.com/jeremytregunna/ruby-trello)



