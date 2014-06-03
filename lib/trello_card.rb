
# Trello Card Manipulation
class TrelloCard
  # Finds a card due to naming convention
  # Review_1337_name_of_pr_trello_shortid_454
  def self.find_card(trelloid)
    re1='.*?'	# Non-greedy match on filler
    re2='\\d+'	# Uninteresting: int
    re3='.*?'	# Non-greedy match on filler
    re4='(\\d+)'	# Integer Number 1
    re=(re1+re2+re3+re4)
    m=Regexp.new(re,Regexp::IGNORECASE)
    if m.match(trelloid)
      @id=m.match(trelloid)[1]
      puts "found card nr: #{@id}"
      find_card_by_id(@id)
    else
      nil
    end
  end

  def self.find_card_by_id(id)
    @board.cards.find{|c| c.short_id == id.to_i}
  end
  # Finds member by id
  def find_member_by_id(id)
    @board.members.find{|m| m.id == id}
  end

  # Finds member by username
  def find_member_by_username(username)
    @board.members.find{|m| m.username == username}
  end


  # Adds a reviewer the trello card (found by (find_card))
  def self.add_reviewer_to_card(card)
    assignees = card.member_ids.map{|id| find_member_by_id(id)}
    members = TRELLO_CONFIG['member'].map{|name| find_member_by_username(name) }
    available_ids = members.map(&:id) - assignees.map(&:id)
    reviewer = available_ids.map{|id| find_member_by_id(id)}.sample
    # removes already assigned==owner of the card from the reviewers list
    if reviewer
      card.add_member(reviewer)
      card.add_comment("#{reviewer.username} will review it")
      puts "added #{reviewer} to the card"
      return true
    else
      puts "No available reviewer found"
    end
    false
  end

  # Automatically moves the card to the right column.
  def move_card_to_list(card, repo, number)
    if (pull_merged?(repo, number))
      # If reviewstatus is closed or merged move card to done
      list_done= @board.lists.find {|x| x.name == 'Done'}
      card.move_to_list(list_done.id)
      puts "moved to #{list_done.name}"
    else
      ## if reviewstatus is open or merged move card to inReview
      list_in_review = @board.lists.find {|x| x.name == 'in review'}
      card.move_to_list(list_in_review.id)
      puts "moved to #{list_in_review.name}"
    end
  end
end
