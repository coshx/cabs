module CoordinatesHelper

  require 'open-uri'

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

  def get_directions
    startCoord = get_coordinates
    endCoord = get_coordinates
    startAddr = URI::encode(HTTParty.get('https://maps.googleapis.com/maps/api/geocode/json?latlng='+startCoord[0].to_s+','+startCoord[1].to_s+'&key=AIzaSyAuAQGWRXZ1t-sjDqU0zWVZWmdOBIoHbOc&location_type=rooftop')['results'][0]['formatted_address'])
    endAddr = URI::encode(HTTParty.get('https://maps.googleapis.com/maps/api/geocode/json?latlng='+endCoord[0].to_s+','+endCoord[1].to_s+'&key=AIzaSyAuAQGWRXZ1t-sjDqU0zWVZWmdOBIoHbOc&location_type=rooftop')['results'][0]['formatted_address'])
    directions = HTTParty.get('https://maps.googleapis.com/maps/api/directions/json?origin='+startAddr+'&destination='+endAddr+'&key=AIzaSyAuAQGWRXZ1t-sjDqU0zWVZWmdOBIoHbOc')
    polyline_array = []
    directions["routes"][0]["legs"][0]["steps"].each do |step|
      encoded_points = step["polyline"]["points"]
      decoded_points = Polylines::Decoder.decode_polyline(encoded_points)
      polyline_array.push(decoded_points)
    end

    polyline_array.flatten!(1)
    return polyline_array
  end


  def build_routes_list
    CSV.open("lib/routes.csv", "ab") do |csv|
      250.times do |n|
        puts "starting #{n}"
        route = get_directions
        csv << route
      end
    end
  end

  def read_routes_list
    routes = CSV.read("lib/routes.csv")
    for m in 0 ... routes.size
      route = routes[m]
      for n in 0 ... route.size
        route[n] = route[n].delete('[]').split(", ").map(&:to_f)
      end
      routes[m]=route
    end
    return routes
  end

end