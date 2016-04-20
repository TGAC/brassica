# Single, generic table_data method for all "browseable" models to reuse
module TableData extend ActiveSupport::Concern
  included do
    def self.table_data(params = nil, uid = nil)
      query = (params && (params[:query] || params[:fetch])) ? filter(params) : all
      query = query.merge(visible(uid))
      query.pluck_columns(uid)
    end
  end
end
