class Brapi::QueryError < StandardError
  attr_reader :sql
  
  def initialize(sql)
    super
    @sql = sql
  end  
end
 