module VehicleFilter

  extend ActiveSupport::Concern

  protected

  def apply_vehicle_filters(vehicles_scope)
    filtered_vehicles = vehicles_scope

    if params[:query].present?
      keyword = params[:query].downcase
      filtered_vehicles = filtered_vehicles.left_joins(driver: :user)
                                         .where("LOWER(vehicles.model) LIKE :keyword OR LOWER(users.name) LIKE :keyword", keyword: "%#{keyword}%")
    end

    if params[:vehicle_type].present? && params[:vehicle_type] != "All"
      filtered_vehicles = filtered_vehicles.by_type(params[:vehicle_type])
    end

    if params[:tag_id].present?
      filtered_vehicles = filtered_vehicles.with_tag(params[:tag_id])
    end

    if params[:min_rating].present?
      filtered_vehicles = filtered_vehicles.with_ratings_above(params[:min_rating].to_f)
    end

    filtered_vehicles
  end
end
