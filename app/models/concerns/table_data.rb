# Single, generic table_data method for all "browseable" models to reuse
module TableData extend ActiveSupport::Concern
  included do
    def self.table_data(params = nil, uid = nil)
      query = (params && (params[:query] || params[:fetch])) ? filter(params) : all
      query = query.where(arel_table[:user_id].eq(uid).or(arel_table[:published].eq(true)))
      query.pluck_columns
    end
  end
end
