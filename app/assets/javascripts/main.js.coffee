Game = {}
$ ->
  Game.canvas = document.getElementById('canvas')
  canvas = Game.canvas
  canvas.width = $(window).width() - 20
  canvas.height = $(window).height()
  Game.ctx = canvas.getContext("2d")
  ctx = Game.ctx
  ctx.fillStyle = "#000000";
  ctx.fillRect(0,0,canvas.width,canvas.height);