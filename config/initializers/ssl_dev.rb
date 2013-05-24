# http://stackoverflow.com/questions/3977303/omniauth-facebook-certificate-verify-failed/5618072#5618072
#if Rails.env.development? 
  OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
#end