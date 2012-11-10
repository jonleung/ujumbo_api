class SessionAuth < Ujumbo::UjumboRecord::Base

  SECURITY_QUESTION = 50  #
  PASSWORD = 40           # 
  PASSWORD_RESET = 30     #  
  NORMAL = 22             # Token Cookie Styored
  UNSECURE = 20           # ie from Email
  PUBLIC = 10             # 

end