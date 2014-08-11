window.Game ||= {}
window.Assets ||= {}

Game.Map =
  pos: [0, 0]
  image: Assets.Map.sprite
  load: ->
    image = new Image()
    image.src = @image
    @sprite = image

  render: (index) ->
    ctx = Game.ctx
    x =  @pos[0]
    y =  @pos[1]
    if @sprite
      ctx.drawImage(@sprite, x, y)

Map = Game.Map

Game.Objects = {}

class Game.Objects.Car
  speed: 0
  step: 5
  pos: [100, 100]
  width: 70
  height: 70
  loaded: false
  spritesLoaded: 0
  image: Assets.BlackUber.sprite
  deadImage:  Assets.BlackUber.explodeSprite
  angle: 100
  uturn: 0
  alive: true
  distance: 0
  makeUturn: ->
    if @uturn <= 0
      @uturn = 180
  kill: ->
    @alive = false
    Game.objects.splice(Game.objects.indexOf(@), 1)
    Game.objects.unshift(@)
  currentSprite: ->
    if @alive
      @sprite
    else
      @deadSprite
  load: ->
    image = new Image()
    image.src = @image
    @sprite= image
    image = new Image()
    image.src = @deadImage
    @deadSprite = image
  render: (index) ->
    @move(index)
    ctx = Game.ctx
    x = @pos[0] + @width /2 + Game.Map.pos[0]
    y = @pos[1] + @height/2 + Game.Map.pos[1]
    ctx.save()
    ctx.translate(x, y)
    ctx.rotate(@angle * Math.PI / 180)
    if @sprite
      ctx.drawImage(@currentSprite(), -@width/2, -@height/3*2)
    ctx.restore()
  move: (index) ->
    if @alive
      x = @pos[0] + @width /2
      y = @pos[1] + @height/2


      if (y < @width || x < @height || x > Game.canvas.width - @width|| y > Game.canvas.height - @height)&&(@uturn <= 0)
        @makeUturn()
      lag = index * 100
      x = Math.sin(@angle * Math.PI/180) * lag
      y = Math.cos(@angle * Math.PI/180) * lag
      @pos[0] = @pos[0] + x
      @pos[1] = @pos[1] - y
      @distance = @distance + index
      currentStep = Math.round(@distance/0.15)
      if currentStep != @currentStep
        if currentStep/3 == Math.floor(@currentStep/3)
          if @uturn <= 0
            @angle = @angle + (Math.random() * 50 - 25)
          else
            @uturn = @uturn - 10
            if @uturn >= 110
              @angle = @angle - 30

      @currentStep = currentStep

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