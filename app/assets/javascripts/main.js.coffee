window.Game ||= {}
window.Assets ||= {}
Game.Objects ||= {}
window.Routes ||= []

Map = Game.Map

Game.randomRoute = ->
  n = Routes.length
  Routes[Math.round(Math.random() * n)]

Game.Map.load()
Game.objects = []

$ ->
  $(".fade").fadeIn()
  Game.canvas = document.getElementById('canvas')
  Game.canvas.addEventListener 'mousedown', (e) ->
    for object in Game.objects
      x = object.pos[0] + Map.pos[0]
      y = object.pos[1] + Map.pos[1] - object.height / 2
      console.log "X ", e.clientX, x
      a = 20
      if e.clientX > x - a && e.clientX < x + object.width + a && e.clientY > y - a && e.clientY < y + object.height + a
        object.kill(true)
  canvas = Game.canvas
  canvas.width = Game.Map.width
  canvas.height = Game.Map.height
  Game.ctx = canvas.getContext("2d")
  ctx = Game.ctx
  ctx.fillStyle = "#000000"
  ctx.fillRect(0, 0, canvas.width, canvas.height)
  Game.main()
  $(".button").click ->
    $(".fade").fadeOut()
    Game.objects.push new Game.Objects.UberCar()

Game.render = (index) ->
  ctx = Game.ctx
  canvas = Game.canvas
  ctx.fillStyle = '#345678'
  ctx.fillRect(0, 0, canvas.width, canvas.height)
  Game.Map.render()
  for object in Game.objects
    object.render(index)

Game.lastTime = Date.now()

alive = (a) ->
  a.alive


#main loop
Game.main = ->
  now = Date.now()
  dt = (now - Game.lastTime) / 1000.0
  Game.render(dt)
  Game.lastTime = now
  if Game.objects.filter(alive).length < 5
    Game.objects.push new Game.Objects.UberCar()
  window.setTimeout Game.main, 1000 / 60
