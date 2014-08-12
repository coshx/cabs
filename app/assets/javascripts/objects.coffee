window.Game ||= {}
window.Assets ||= {}
Game.Objects = {}

Game.User =
  score: 0
  addScore: ->
    @score = @score + 1
    @render()
  render: ->
    $("#score").text(@score)

Game.Map =
  topLeft: [40.758014, -74.013621]
  bottomRight: [40.733368, -73.959291]
  pos: [0, 0]
  image: Assets.Map.sprite
  width: 1251
  height: 766
  load: ->
    image = new Image()
    image.src = @image
    @sprite = image
    @px = Game.Map.width /  (Game.Map.bottomRight[1] - Game.Map.topLeft[1])
    @py = Game.Map.height / (Game.Map.topLeft[0] - Game.Map.bottomRight[0])
    console.log @px

  render: (index) ->
    ctx = Game.ctx
    x =  @pos[0]
    y =  @pos[1]
    if @sprite
      ctx.drawImage(@sprite, x, y)

class Game.Objects.UberCar
  route: [[40.745237, -73.998481], [40.740328, -73.986379], [40.747221, -73.981315], [40.754536, -73.999082]]
  pos: [0, 0]
  speed: 0
  step: 5
  toX: (coordinate) ->
    Game.Map.width -  (coordinate - Game.Map.bottomRight[1]) * Game.Map.px * -1 - @width / 2
  toY: (coordinate) ->
    Game.Map.height - (coordinate - Game.Map.bottomRight[0]) * Game.Map.py  - @height / 2
  getPos: ->
    @pos[0] = @toX @route[0][1]
    @pos[1] = @toY @route[0][0]
  getNextDestination: ->
    @distance = 0
    @currentDestination = @currentDestination + 1
    @distCoordinates = @route[@currentDestination]
    @distPos = []
    @distPos[1] = @toY @distCoordinates[0]
    @distPos[0] = @toX @distCoordinates[1]
    ex = @distPos[0]
    ey = @distPos[1]
    cx = @pos[0]
    cy = @pos[1]
    dy = ey - cy
    dx = ex - cx
    @angle = Math.atan2(dy, dx)
    @angle *= 180/Math.PI + 180
    console.log @angle, @pos, @distPos
    @currentDistance = @getDistance(@pos, @distPos)

  width: 70
  height: 70
  loaded: false
  deadImage:  Assets.BlackUber.explodeSprite
  uturn: 0
  alive: true
  distance: 0
  constructor: ->
    @currentDestination = 0
    @load()
    @getPos()
    @getNextDestination()
  makeUturn: ->
    if @uturn <= 0
      @uturn = 180
  kill: ->
    @alive = false
    Game.objects.splice(Game.objects.indexOf(@), 1)
    Game.objects.unshift(@)
    Game.User.addScore()
  currentSprite: ->
    if @alive
      @sprite
    else
      @deadSprite
  load: ->
    image = new Image()
    image.src = @image
    @sprite = image
    image = new Image()
    image.src = @deadImage
    @deadSprite = image

  image: Assets.BlackUber.sprite
  getDistance: (point1, point2) ->
    xs = point2[0] - point1[0]
    xs = xs * xs

    ys = point2[1] - point1[1]
    ys = ys * ys

    Math.sqrt( xs + ys )

  move: (index) ->
    if @alive
      x = @pos[0]
      y = @pos[1]

      if (y < @width || x < @height || x > Game.canvas.width - @width|| y > Game.canvas.height - @height)&&(@uturn <= 0)
        @makeUturn()
      lag = index * 100
      x = Math.sin(@angle * Math.PI/180) * lag
      y = Math.cos(@angle * Math.PI/180) * lag
      @pos[0] = @pos[0] + x
      @pos[1] = @pos[1] - y
      @distance = @distance + index * 100
      if @distance >= @currentDistance
        @getNextDestination()

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

class Game.Objects.LyftCar
  speed: 0
  step: 5
  pos: [100, 100]
  width: 70
  height: 70
  loaded: false
  spritesLoaded: 0
  deadImage:  Assets.BlackUber.explodeSprite
  angle: 100
  uturn: 0
  alive: true
  distance: 0
  constructor: ->
    @load()
  makeUturn: ->
    if @uturn <= 0
      @uturn = 180
  kill: ->
    @alive = false
    Game.objects.splice(Game.objects.indexOf(@), 1)
    Game.objects.unshift(@)
    Game.User.addScore()
  currentSprite: ->
    if @alive
      @sprite
    else
      @deadSprite
  load: ->
    image = new Image()
    image.src = @image
    @sprite = image
    image = new Image()
    image.src = @deadImage
    @deadSprite = image

  image: Assets.Lyft.sprite

  render: (index) ->
    @move(index)
    ctx = Game.ctx
    x = @pos[0] + @width /2 + Game.Map.pos[0]
    y = @pos[1] + @height/2 + Game.Map.pos[1]
    if @sprite
      ctx.drawImage(@currentSprite(), x, y)

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



