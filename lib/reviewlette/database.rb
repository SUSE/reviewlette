require 'sequel'
module Reviewlette

  class Database

    FileUtils.mkdir_p("#{File.join(ENV['HOME'])}/.config/reviewlette/") unless Dir.exists?("#{ENV['HOME']}/.config/reviewlette")
    FileUtils.cp ("#{File.dirname(__FILE__)}/../../reviewlette.db"), ("#{File.join(Dir.home)}" + '/.config/reviewlette/') unless File.exists?(("#{File.join(Dir.home)}" + '/.config/reviewlette/reviewlette.db'))

    @path = "#{File.join(ENV['HOME'])}/.config/reviewlette"
    DATABASE = Sequel.connect("sqlite://#{@path}/reviewlette.db")

    attr_accessor :reviewer, :reviews

    def initialize

      @reviewer = DATABASE.from(:reviewer)
      @reviews = DATABASE.from(:reviews)
      # require 'byebug'
      # byebug
    end

    def count_up(reviewer)
      pr_reviewer = @reviewer.where(:trello_name => reviewer).select(:trello_name).first.values.first
      counter = @reviewer.where(:trello_name => pr_reviewer).select(:reviews).first.values.first
      @reviewer.where(:trello_name => reviewer).update(:reviews => counter.next)
    end

    def add_pr_to_db(pr_name, reviewer)
      @reviews.insert(:name => pr_name, :reviewer => reviewer, :created_at => Date.today)
      count_up(reviewer)
    end

    def get_users_tel_entries
      @reviewer.map([:tel_name]).flatten.select{|user| user unless user.nil?}
    end

    def get_users_gh_entries
      @reviewer.map([:gh_name]).flatten.select{|user| user unless user.nil?}
    end

    def get_users_trello_entries
      @reviewer.where(:vacation => 'false').map([:trello_name]).flatten.select{|user| user unless user.nil?}
    end

    def count_reviews(reviewer)
      @reviews.where(:reviewer => reviewer).count
    end

    def find_gh_name_by_trello_name(trello_name)
      @reviewer.where(:trello_name => trello_name).select(:gh_name).first.values.first
    end

    def set_vacation_flag(reviewer, state)
      @reviewer.where(:tel_name => reviewer).update(:vacation => state)
    end

    def conscruct_graph_struct
      data = []
      get_users_trello_entries.each do |x|
        data.push({ label: x, value: count_reviews(x) })
      end
      data
    end

    def conscruct_line_data
      data = []
      date_range = (Date.today - 7 )..(Date.today)
      get_users_trello_entries.each do |name|
          date_range.each do |date|
          abc = {}
          abc[:created_at] = date
          abc[name] = @reviews.where(:reviewer => name, :created_at => date).select(:created_at).count
          data.push(abc)
          end
      end
      data
    end
  end
end
