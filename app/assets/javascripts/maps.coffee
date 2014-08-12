window.Assets ||= {}

$ ->
  initialize = ->
    mapOptions =
      center: new google.maps.LatLng(40.744, -73.988)
      zoom: 15
      disableDefaultUI: true
      draggable: false
      disableDoubleClickZoom: true

    map = new google.maps.Map(document.getElementById("map-canvas"), mapOptions)
    image = Assets.BlackUber.sprite
    myLatLng = new google.maps.LatLng(40.744, -73.988)
    beachMarker = new google.maps.Marker(
      position: myLatLng
      map: map
      icon: image
    )

  google.maps.event.addDomListener window, "load", initialize