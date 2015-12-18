blessed = require('blessed')
# Create a screen object.
screen = blessed.screen(smartCSR: true)

# Create a box perfectly centered horizontally and vertically.
styling = ->
  width: '50%'
  height: '50%'
  content: ""
  tags: true
  border: type: 'line'
  scrollable : true
  scrollbar:
    bf: 'red'
    fg: 'blue'
  style:
    fg: 'white'
    bg: 'magenta'
    border: fg: '#f0f0f0'
style = styling()
style.top = 0
style.left = 0
box = blessed.box(style)
style = styling()
style.right = 0
style.top = 0
box2 = blessed.box(style)
style = styling()
style.left = 0
style.bottom = 0
box3 = blessed.box(style)
style = styling()
style.bottom = 0
style.right = 0
box4 = blessed.box(style)

screen.append box
screen.append box2
screen.append box3
screen.append box4

# Quit on Escape, q, or Control-C.
screen.key [
  'escape'
  'q'
  'C-c'
], (ch, key) ->
  process.exit 0

_ = require 'lodash'
exports.screen1 = _.throttle (data) ->
  box.setContent "screen\n#{new Date()}\n#{data}"
  screen.render()
, 1000
exports.screen2 = _.throttle (data) ->
  box2.setContent "screen2\n#{new Date()}\n#{data}"
  screen.render()
, 1000
exports.screen3 = _.throttle (data) ->
  box3.setContent "screen3\n#{new Date()}\n#{data}"
  screen.render()
, 1000
exports.screen4 = _.throttle (data) ->
  box4.setContent "screen4\n#{new Date()}\n#{data}"
  screen.render()
, 1000
# Render the screen.
screen.render()
