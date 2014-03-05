class Reviewlette

  attr_accessor :name

  def initialize
    
  end
  def namereturn
    'jschmid'
  end
  def exp(zahl)
    zahl * zahl
  end
  def randomname
    @namelist = ['jschmid', 'fbayerlein', 'dbamberger', 'tschmidt', 'sschubert', 'vlewin', 'achernikov', 'wspepahnson']
    @name = @namelist.sample
  end
  def namecall
    randomname unless @name
   "its your turn #{@name}"
  end
end

roulette= Reviewlette.new
roulette.namecall




	


