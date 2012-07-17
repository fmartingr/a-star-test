class Grid
  terrain: []

  constructor: ->
    @element = document.getElementsByTagName('grid')[0]
    @x = parseInt @element.getAttribute 'x'
    @y = parseInt @element.getAttribute 'y'
    if not @element
      @error 'Could not found <grid> in DOM!'
      false
    else
      @log "#{@x}x#{@y} grid created."
      @makeTerrain()
      @showTerrain()

  makeTerrain: ->
    for y in [0..@y]
      @terrain.push (new Terrain for x in [0..@x])

  showTerrain: ->
    yy = 0
    xx = 0
    for y in @terrain
      if yy < 20 then yy++ else yy = 1
      for x in y
        if xx < 20 then xx++ else xx = 1
        element = document.createElement 'Terrain'
        element.setAttribute 'x', xx
        element.setAttribute 'y', yy
        element.style.background = x.color
        @element.appendChild(element)
    for y in [1..@y]
      if yy < @y then yy++ else yy = 1
      for x in [1..@x]
        if xx < @x then xx++ else xx = 1

    element = document.getElementsByTagName('terrain')[0]
    gridSize = (parseInt element.scrollHeight * @x)
    @element.style.width = "#{gridSize}px";
    console.log @element.style.width


  error: (msg) ->
    console.error msg

  log: (msg) ->
    console.log msg


class Terrain
  # types: air, liquid, solid
  type: 'air'
  color: 'white'

  isSolid: ->
    @type is not 'air'

###
class Air extends Terrain


class Water extends Terrain
  type: 'liquid'
  color: 'blue'

class Rock extends Terrain
  type: 'solid'
  color: 'brown'
###

grid = new Grid