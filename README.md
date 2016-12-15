[![Code Climate](https://codeclimate.com/github/SUSE/reviewlette.png)](https://codeclimate.com/github/SUSE/reviewlette)
[![Build Status](https://secure.travis-ci.org/SUSE/reviewlette.png?branch=master)](https://travis-ci.org/SUSE/reviewlette)

# Reviewlette
Tool to automatically assign reviewers to GitHub pull requests and to move and comment on their Trello cards.

What it does:

- Finds pull requests with missing reviewers in your GitHub repos.
- Assigns random members of your team.
- Locates the right card in your Trello board.
- Mentions the assigned reviewer in a comment on the card.
- Moves the card to the 'In review' column.

## Installation
For the latest and greatest version you should `git clone https://github.com/SUSE/reviewlette`

## Usage
```ruby
Reviewlette.new(members: User.all, github_config: {}, trello_config: {}).run
```

Users must respond to `trello_handle` and `github_handle` methods.

Examples for `github_config` and `trello_config` can be found in `config/`.

### Matching Trello cards
To match a Trello card to a pull request, its title has to end with the card number (not the id)

#### Example:

URL of the Trello card: _https://trello.com/c/cardid/4242-fix-everything_

Pull request title should be: `Fix almost everything 4242`

__Note:__ Pull requests without a matching Trello card get skipped and won't be assigned to a reviewer.

### Labels
You can tweak Reviewlette's behavior by adding special labels to your pull request:

| Label       | Description          |
|-------------|----------------------|
| 2 reviewers | Assign two reviewers |
