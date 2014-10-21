local application = require "mjolnir.application"
local hotkey = require "mjolnir.hotkey"
local window = require "mjolnir.window"
local fnutils = require "mjolnir.fnutils"
local screen = require "mjolnir.screen"
local geometry = require "mjolnir.geometry"

local alert = require "mjolnir.alert"

local hyper = {"ctrl", "alt", "cmd", "shift"}
local windowstates = {}
local horizontals = { 0, 1/4, 1/3, 1/2, 2/3, 3/4, 1 }
local verticalfractions = { 0, 1/3, 1/2, 2/3, 1 }
local CENTER_X = 4
local CENTER_Y = 3

fnutils.each(window.allwindows() , function (w)
  windowstates[w.id] = { left = 0, right = 8 }
end ) 

alert.show("initial setup complete" , 1) 

function update_window(window, left_index, right_index)
  alert.show("moving to left:"..left_index.." right:"..right_index, 2)
  if left_index <= 0 or left_index >= 8
    or right_index <= 0 or right_index >= 8 then
    return
  end
  if right_index == 1 or left_index == 7 then return end
  windowstates[window.id] = { left = left_index, right = right_index }
  local screen = screen.mainscreen():fullframe()
  local width = screen.w
  local height = screen.h
  local newframe = geometry.rect(
                        horizontals[left_index] * width,
                        0,
                        horizontals[right_index-left_index + 1] * width,
                        height)
  alert.show("left: " .. left_index .. ", right: " .. right_index,2)
  window:setframe(newframe)
end

function getstate(window)
  return windowstates[window.id]
end

function setRight(window)
  update_window(window, CENTER_X, 7)
end

function setLeft(window)
  update_window(window, 1, CENTER_X)
end

function pushRight(window)
  local s = getstate(window)
  update_window(window, s.left + 1, s.right)
end

function pushLeft(window)
  local s = getstate(window)
  update_window(window, s.left, s.right - 1)
end

function extendRight(window)
  local s = getstate(window)
  update_window(window, s.left, s.right + 1)
end

function extendLeft(window)
  local s = getstate(window)
  alert.show("extending left", 2)
  update_window(window, s.left - 1, s.right)
end

function pushTop(window)
  local s = getstate(window)
  update_window(window, s.left, s.right, s.top, s.bot - 1)
end

function pushBot(window)
  local s = getstate(window)
  update_window(window, s.left, s.right, s.top - 1, s.bot)
end

function fullscreen(window)
  update_window(window, 1, 7)
end

function is_at_right(state)
  return state.right == 7
end

function is_at_left(state)
  return state.left == 1
end

-- KEY BINDING --
hotkey.bind(hyper, "D", function()
  local win = window.focusedwindow()
  local s = getstate(win)
  if is_at_right(s) then 
    pushRight(win)
  else
    setRight(win)
  end
end)

hotkey.bind(hyper, "A", function()
  local win = window.focusedwindow()
  local s = getstate(win)
  if is_at_left(s) then 
    pushLeft(win)
  else
    setLeft(win)
  end
end)

hotkey.bind(hyper, "E", function()
  local win = window.focusedwindow()
  local s = getstate(win)
  extendRight(win)
end)

hotkey.bind(hyper, "Q", function()
  local win = window.focusedwindow()
  local s = getstate(win)
  extendLeft(win)
end)

hotkey.bind(hyper, "F", function()
  fullscreen(window.focusedwindow())
end)

hotkey.bind(hyper, "=", function()
  alert.show("reloading config", 2)
  mjolnir.reload()
end)
