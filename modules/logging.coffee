blessed = require('blessed')
# Create a screen object.
screen = blessed.screen(smartCSR: true)
cson = require 'cson'
_ = require 'lodash'

# Create a box perfectly centered horizontally and vertically.
styling = ->
  width: '50%'
  style:
    fg: 'white'
    bg: 'magenta'
    border: fg: '#f0f0f0'

totalOdd = 0
totalEven = 0
newBox = (idx, height = 10) ->
  style = styling()
  if (idx % 2) is 0
    style.left = 0
    style.top = totalOdd
    totalEven += height
  else
    style.right = 0
    style.top = totalOdd
    totalOdd += height
  style.height = height
  box = blessed.box(style)
  screen.append box
  box

# Quit on Escape, q, or Control-C.
screen.key [
  'escape'
  'q'
  'C-c'
], (ch, key) ->
  process.exit 0

module.exports = (idx, height) ->
  box = newBox idx, height
  box.setContent idx.toString()
  return _.throttle (data) ->
    if _.isObject data
      data = "#{cson.stringify data,null, 2}"

    data = "#{idx} #{new Date()}\n#{data}"
    box.setContent data
    screen.render()
  , 1000

# Render the screen.
screen.render()
