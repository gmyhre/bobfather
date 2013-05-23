Rails.application.config.middleware.use OmniAuth::Builder do
  OmniAuth.config.logger = Rails.logger
  
  provider :facebook, '529867487070709', '66ce6116694ce0457d81a394161c108b',
  :scope => 'email' #,
  # :client_options => {:ssl => {:ca_path => "/etc/ssl/certs"}}
end

# Bobfather
# App ID: 
# App Secret: 66ce6116694ce0457d81a394161c108b(reset)
