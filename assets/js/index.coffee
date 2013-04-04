$ ->
  console.log 'hallo'
  canvas = $('#graphCanvas').get(0)
  ctx = canvas.getContext "2d"
  ctx.fillStyle = '#AAEEFF'
  ctx.fillRect 0, 0, 150, 75
