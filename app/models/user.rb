class User < Ujumbo::UjumboRecord::Base
  include Redis::Objects
  
  attr_accessible :first_name, :last_name

end