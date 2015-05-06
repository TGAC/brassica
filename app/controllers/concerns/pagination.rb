module Pagination
  extend ActiveSupport::Concern

  included do

    def page_params
      @page_params ||= {
        page: params[:page] || 1,
        per_page: params[:per_page]
      }
    end

    def paginate_collection(collection)
      if page_params[:page]
        collection = collection.page(page_params[:page])
        collection = collection.per(page_params[:per_page]) if page_params[:per_page]
      end
      collection
    end

  end

end
