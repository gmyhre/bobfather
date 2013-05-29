class User < Neo4j::Rails::Model
  property :name, :type => String, :index => :exact
  property :email, :type => String
  property :fbid, :type => String, :index => :exact, :unique => true
  property :registered, :type => :boolean, :default => false #, :index => :exact
  
  property :fb_access_token, :type => String
  property :favorite_donut, :type => String, :index => :exact
  property :last_login, :type => Time
  property :state, :type => String, :index => :exact
  # use this as an explicity indication of Bobfatherhood by the user
  property :is_bobfather, :type => :boolean, :default => false
  # use this as a property for traversal
  # property :has_bobfather, :type => :boolean, :default => false
  
  
  has_one(:bobfather)
  has_n(:friends)
  
  UNKNOWN_BOBFATHER = '0'
  I_AM_BOBFATHER = '-1'

  FEATUREALBE = "featurable"
  
  attr_accessible :fbid, :name, :email, :registered, :is_bobfather
  attr_accessible :bobchildren
  
  def has_bobfather?
    self.bobfather ? true : false
  end
  
  def related?(user)
    self.relation(user).count > 0
  end

  # Todo
  # figure out how to exit the search after a found path?
  # end_node.id == user.id should work, but doesn't
  def relation(user)
    traversal = self.both(:bobfather).depth(:all).unique(:node_path).eval_paths { |path|  (path.end_node[:fbid] == user[:fbid]) ? :include_and_continue : :exclude_and_continue }
    # self.both(:bobfather).depth(:all).filter{|path| path.end_node.rel?(:recommend, :incoming)}.
    #     each{|node| puts node[:name]}
    
    #traversal = self.both(:bobfather).depth(:all).unique(:node_path).eval_paths { |path|  puts path.end_node ; puts path.end_node.id ; :include_and_continue }
    # traversal = self.both(:bobfather).depth(:all).unique(:node_path).eval_paths { |path|  :include_and_continue }
    # traversal = u1.both(:bobfather).depth(:all).unique(:node_path).eval_paths { |path|  :include_and_continue }
    return traversal
  end

  # who is the bobfather at the top of the lineage
  def don_bobfather
    #traversal = self.outgoing(:bobfather).depth(:all).unique(:node_path).eval_paths { |path|  (path.end_node[:fbid] == user[:fbid]) ? :include_and_continue : :exclude_and_continue }
    traversal = self.outgoing(:bobfather).depth(:all).to_a.last #.   #filter{|path| path.end_node.has_bobfather?}.
      #   each{|node| puts node[:name]}
  end

  def has_bobchildren?
    self.incoming(:bobfather).count > 0
  end
  
  def bobchildren
    self.incoming(:bobfather)
  end
  
  def lineage_total
    self.incoming(:bobfather).depth(:all).count
  end


  # business logic of who gets to delete what can go here
  def update_bobchildren(bobchildren_ids)
    bobchildren_ids.reject! {|x| x.empty? }
    existing_bobchildren_ids = bobchildren.collect {|x| x.id}
    delete_child_relaitonships = existing_bobchildren_ids - bobchildren_ids
    Rails.logger.info("existing_bobchildren::#{existing_bobchildren_ids}")
    Rails.logger.info("delete_child_relaitonships::#{delete_child_relaitonships}")
    
    delete_child_relaitonships.each do |uid|
      u = User.find(uid)
      u.bobfather_rel.destroy
    end
    
    bobchildren_ids.each do |child_id|
      u = User.find(child_id)
      u.bobfather = self 
      # do state machine
      u.bobfather_rel[:state] = 'proposed by father'
      u.save
    end
  end

  
  def update_bobfather(bobfather_id)
    if bobfather_id == UNKNOWN_BOBFATHER
      Rails.logger.info("User has An Out of Network Bobfather")
      self.bobfather_rel.destroy if self.bobfather
        
    elsif bobfather_id == I_AM_BOBFATHER
      self.bobfather_rel.destroy if self.bobfather
    elsif !bobfather_id.blank?
      u = User.find(bobfather_id)
      self.bobfather = u
      # do state machine
      self.bobfather_rel[:state] = 'proposed'
      save
    else
      Rails.logger.info("User has no Bobfather")
    end
  end
  
  def bobfather_status
    plug = ''
    plug = ".  Invite them to sign up" if not registered?
    return "#{self.name } is the bobfather#{plug}"
  end
  
  def update_from_fb_omniuath(auth)
    uinfo = auth['info'] # with changes to the user info hash from authentication with facebook    
    raise "Missing user info in auth" if uinfo.nil?    
    # raise "Missing auth" if auth.nil?
    # Rails.logger.info("\n\nFacebook User::#{auth.inspect}\n\n#{uinfo.inspect}")
    self.fb_access_token = auth['credentials']['token']
    self.email = uinfo['email']
    self.name = uinfo['name']
  end

  def get_fb_friends
    fb_user = FbGraph::User.me(self.fb_access_token)
    friends = fb_user.friends
    friends.each do |f|
      node = User.find(:fbid => f.identifier)
      if !node
        node = User.create(:fbid => f.identifier)
      end
      node.name = f.name if !node.name
      node.save # has to be here to persist friends name
      self.friends << node
    end
    save
  end
  
  def is_bobfather?
    is_bobfather
  end
  
  def new_registration?
    !registered?
  end
  
  def registered?
    registered
  end


  # og protocal, not request needed
  def fb_image_url(size = nil)
    url = "http://graph.facebook.com/#{self.fbid}/picture"
    url = "#{url.split('?')[0]}?type=large" if size
    url
  end
end
