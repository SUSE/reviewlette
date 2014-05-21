
require 'net/smtp'

module Supporter
  class Mailer
    def send_email(to,opts={})
      opts[:server]      ||= 'localhost'
      opts[:from]        ||= 'review@lette.com'
      opts[:from_alias]  ||= 'Reviewlette'
      opts[:subject]     ||= "Commanding Officer of the Week"
      opts[:body]        ||= ""

      msg = <<END_OF_MESSAGE
From: #{opts[:from_alias]} <#{opts[:from]}>
To: <#{to}>
Subject: #{opts[:subject]}

      #{opts[:body]}
END_OF_MESSAGE

      Net::SMTP.start(opts[:server]) do |smtp|
        smtp.send_message msg, opts[:from], to
      end
    end





## make this more generic in order to use it either for COotW and PairProgramming sessions aand reviews
  end
end
# name = "asd"
# a= Supporter::Mailer.new
# a.send_email "jschmid@suse.de", :body => "#{name}"