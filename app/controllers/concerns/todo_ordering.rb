class TodoOrdering
  include ActiveSupport::Concern

  def self.extract_sort_and_order(params)
    order = params[:order]&.strip&.downcase == 'asc' ? :asc : :desc

    sort_by = params[:sort_by]&.strip&.downcase

    order, sorb_by
  end
end
