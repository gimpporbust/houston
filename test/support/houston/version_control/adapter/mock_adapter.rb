module Houston
  module VersionControl
    module Adapter
      class MockAdapter
        
        def self.problems_with_location(*args)
          []
        end
        
        def self.create_repo(*args)
          Houston::VersionControl::NullRepo
        end
        
      end
    end
  end
end