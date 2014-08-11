module CoordinatesHelper

  def get_coordinates
    left_edge = -74.007
    right_edge = -73.966
    top_edge = 40.754
    bottom_edge = 40.736

    triangle_edge = -73.975
    triangle_base = right_edge - triangle_edge
    triangle_height = top_edge - bottom_edge

    random_longitude = rand(left_edge..right_edge)

    if random_longitude < triangle_edge
      min_latitude = bottom_edge
    else
      triangle_ratio = (random_longitude - triangle_edge) / triangle_base
      min_latitude = bottom_edge + (triangle_ratio * triangle_height)
    end

    random_latitude = rand(min_latitude..top_edge)

    coordinates = [random_latitude.round(4), random_longitude.round(4)]

    return coordinates
  end
end