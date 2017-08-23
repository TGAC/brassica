
module Errors
  module Brapi  
    
    # Brapi errors
    class QueryError < StandardError
      attr_reader :sql
      
      def initialize(sql)
        super
        @sql = sql
      end  
    end
    
  end
end