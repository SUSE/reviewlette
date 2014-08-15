require 'json'
require_relative 'database'
module Reviewlette

  class Graphgenerator

    def initialize
      @db = Reviewlette::Database.new
    end

    def write_to_graphs(filename, content)
      File.open(filename, 'w') { |file| file.write(content) }
    end


    def model_graphs(data2, data, type)
      @content = %Q|
      <link rel="stylesheet" href="http://cdn.oesmith.co.uk/morris-0.5.1.css">
      <script src="http://code.jquery.com/jquery-1.11.1.min.js"></script>
      <script src="http://cdnjs.cloudflare.com/ajax/libs/raphael/2.1.0/raphael-min.js"></script>
      <script src="http://cdn.oesmith.co.uk/morris-0.5.1.min.js"></script>
      <meta http-equiv="refresh" content="15" />

      <div id="Donut" style="height: 250px;"></div>
      <div id="Line" style="height: 250px;"></div>
      <div id="Bar" style="height: 250px;"></div>

      <script>
      new Morris.#{type}({
      element: 'Donut',
      data: #{data},
      xkey: 'label',
      colors: ['#80BFFF', '#F0F0F0', '#0000FF', '#00FFFF', '#FF00FF', '#C0C0C0'],
      ykeys: ['value'],
      labels: ['Value']
      });
      </script>

      <script>
      new Morris.Line({
      element: 'Line',
      data: #{data2},
      xkey: 'created_at',
      colors: ['#80BFFF', '#F0F0F0', '#0000FF', '#00FFFF', '#FF00FF', '#C0C0C0'],
      ykeys: #{@db.get_users_trello_entries},
      labels: #{@db.get_users_trello_entries}
      });
      </script>

      <script>
      new Morris.Bar({
      element: 'Bar',
      data: #{data},
      xkey: 'label',
      colors: ['#80BFFF', '#F0F0F0', '#0000FF', '#00FFFF', '#FF00FF', '#C0C0C0'],
      ykeys: ['value'],
      labels: ['Value']
      });
      </script>|
    end
  end
end