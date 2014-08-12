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

class Game.Objects.UberCar
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

  image: Assets.BlackUber.sprite

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



