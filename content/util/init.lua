-- initialise stuff
import = require 'util.import'
require 'util.strict'
require 'util.init_love_events'

-- util library
local library = require 'util.library'
return library (...,
  'Application',
  'Context',
  'Event',
  'FramePacker',
  'List',
  'build',
  'class',
  'import',
  'library',
  'v2',
  'Vec2',
  'help',
  'colorUtil')
