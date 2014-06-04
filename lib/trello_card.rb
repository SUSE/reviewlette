



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
