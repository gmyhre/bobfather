class Bobfather < Neo4j::Rails::Relationship
  property :state, :index => :exact
end