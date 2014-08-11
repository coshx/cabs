window.Game ||= {}
window.Assets ||= {}
Game.Objects ||= {}

Map = Game.Map

Game.Map.load()

cab = new Game.Objects.Car()
cab.load()

Game.objects = []
Game.objects.push cab

$ ->
  Game.canvas = document.getElementById('canvas')
  Game.canvas.addEventListener 'mousedown', (e) ->
    for object in Game.objects
      x = object.pos[0] + Map.pos[0]
      y = object.pos[1] + Map.pos[1]
      console.log "X ", e.clientX, x
      if e.clientX > x && e.clientX < x + object.width && e.clientY > y && e.clientY < y + object.height
        object.kill()
  canvas = Game.canvas
  canvas.width = $(window).width() - 20
  canvas.height = $(window).height()
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
  cab.render(index)

Game.lastTime = Date.now()

#main loop
Game.main = ->
  now = Date.now()
  dt = (now - Game.lastTime) / 1000.0
  Game.render(dt)
  Game.lastTime = now
  window.setTimeout Game.main, 1000 / 60