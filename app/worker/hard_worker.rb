# class HardWorker
#   include Sidekiq::Worker
# 
#   def perform(user_id)
#     user = User.find(user_id)
#     fb_user = FbGraph::User.me(user.fb_access_token)
#     friends = fb_user.friends
#     friends.each do |f|
#       node = User.find(:fbid => f.identifier)
#       if !node
#         node = User.create(:fbid => f.identifier)
#       end
#       node.name = f.name if !node.name
#       node.save # has to be here to persist friends name
#       user.friends << node
#     end
#     save
#     puts "hey there i'm in a worker"
#   end
# end