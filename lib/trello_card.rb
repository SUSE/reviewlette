
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
