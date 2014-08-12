window.Game ||= {}
window.Assets ||= {}
Game.Objects ||= {}

Map = Game.Map

Game.Map.load()
lyft = new Game.Objects.LyftCar()

cab = new Game.Objects.UberCar()

Game.objects = []
Game.objects.push cab
Game.objects.push lyft

$ ->
  Game.canvas = document.getElementById('canvas')
  Game.canvas.addEventListener 'mousedown', (e) ->
    for object in Game.objects
      x = object.pos[0] + Map.pos[0] 
      y = object.pos[1] + Map.pos[1] - object.height / 2
      console.log "X ", e.clientX, x
      a = 20
      if e.clientX > x - a && e.clientX < x + object.width + a && e.clientY > y - a && e.clientY < y + object.height + a
        object.kill()
  canvas = Game.canvas
  canvas.width = Game.Map.width
  canvas.height = Game.Map.height
  Game.ctx = canvas.getContext("2d")
  ctx = Game.ctx
  ctx.fillStyle = "#000000"
  ctx.fillRect(0, 0, canvas.width, canvas.height)
  Game.main()

Game.render = (index) ->
  ctx = Game.ctx
  canvas = Game.canvas
  ctx.fillStyle = '#345678'
  ctx.fillRect(0, 0, canvas.width, canvas.height)
  Game.Map.render()
  for object in Game.objects
    object.render(index)

Game.lastTime = Date.now()

#main loop
Game.main = ->
  now = Date.now()
  dt = (now - Game.lastTime) / 1000.0
  Game.render(dt)
  Game.lastTime = now
  window.setTimeout Game.main, 1000 / 60