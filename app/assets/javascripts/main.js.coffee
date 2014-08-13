window.Game ||= {}
window.Assets ||= {}
Game.Objects ||= {}
window.Routes ||= []

Map = Game.Map

Game.randomRoute = ->
  n = Routes.length - 1
  Routes[Math.round(Math.random() * n)]

Game.Map.load()
Game.objects = []

$ ->
  $(".fade").fadeIn()
  Game.canvas = document.getElementById('canvas')
  Game.canvas.addEventListener 'mousedown', (e) ->
    killed = 0
    for object in Game.objects.filter(Game.alive)
      x = object.pos[0] + Map.pos[0]
      y = object.pos[1] + Map.pos[1]
      a = 30
      if e.clientX > x - a && e.clientX < x + object.width + a && e.clientY > y - a && e.clientY < y + object.height + a
        object.kill(true)
        killed = killed + 1
    Game.User.addScore((killed - 1) * 5)
  canvas = Game.canvas
  canvas.width = Game.Map.width
  canvas.height = Game.Map.height
  Game.ctx = canvas.getContext("2d")
  ctx = Game.ctx
  ctx.fillStyle = "#000000"
  ctx.fillRect(0, 0, canvas.width, canvas.height)
  Game.render(0)
  $(".button").click ->
    Game.main()
    $(".fade").fadeOut()
    Game.objects.push new Game.Objects.BlackUberCar()

Game.render = (index) ->
  ctx = Game.ctx
  canvas = Game.canvas
  ctx.fillStyle = '#345678'
  ctx.fillRect(0, 0, canvas.width, canvas.height)
  Game.Map.render()
  for object in Game.objects
    object.render(index)

Game.lastTime = Date.now()
Game.startTime = Date.now()

Game.alive = (a) ->
  a.alive

Game.updateTimer = ->
  Game.timer = Math.round((Game.lastTime - Game.startTime) / 1000)
  # not to update every 1/60 second
  if Game.timer != Game.lastTimer
    $("#timer").text(Game.timer)
  Game.lastTimer = Game.timer


#main loop
Game.main = ->
  now = Date.now()
  dt = (now - Game.lastTime) / 1000.0
  Game.updateTimer()
  Game.render(dt)
  Game.lastTime = now

  if Game.objects.filter(Game.alive).length < 5
    if Math.round(Math.random() * 100) > 98
      Game.objects.push new Game.Objects.LyftCar()
    else if Math.round(Math.random() * 100) > 60
      Game.objects.push new Game.Objects.BlackUberCar()
    else
      Game.objects.push new Game.Objects.XUberCar()

  window.setTimeout Game.main, 1000 / 60
