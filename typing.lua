-- sol2_typings.lua
---@meta
---@diagnostic disable: undefined-global, undefined-field

-- Globals provided by C++ via sol2

-- Core globals
---@type string
_ = fun()
---@type number
ticks = func()

-- Core functions
---@param url string
function openurl(url) end

---@param state any
---@param module string
---@return function
function searcher(state, module) end

-- JSON utilities
---@class JSON
---@field parse fun(json:string):table
---@field stringify fun(tbl:table):string
JSON = {}

-- Enums
---@enum SceneType
SceneType = { object = 0, effect = 1 }

---@enum Controller
Controller = { up = 0, down = 1, left = 2, right = 3, triangle = 4, circle = 5, cross = 6, square = 7 }

---@enum Anchor
Anchor = { top = 0, bottom = 1, left = 2, right = 3, none = 4 }

---@enum Reflection
Reflection = { none = 0, horizontal = 1, vertical = 2, both = 3 }

---@enum Player
Player = { one = 0, two = 1 }

---@enum WidgetType
WidgetType = { cursor = 0, label = 1 }

---@enum KeyEvent
KeyEvent = { up = 0, left = 1, down = 2, right = 3, space = 4 }

-- Usertype definitions
---@class SoundFX
---@field play fun(self:SoundFX, loop?:boolean)
---@field stop fun(self:SoundFX)
SoundFX = {}

---@class SoundManager
---@field play fun(self:SoundManager, name:string, loop?:boolean)
---@field stop fun(self:SoundManager)
SoundManager = {}

---@class ReflectionProxy
---@field set fun(self:ReflectionProxy, value:Reflection)
---@field unset fun(self:ReflectionProxy)
ReflectionProxy = {}

---@class ActionProxy
---@field set fun(self:ActionProxy, value:string)
---@field get fun(self:ActionProxy):string
---@field unset fun(self:ActionProxy)
ActionProxy = {}

---@class PlacementProxy
---@field set fun(self:PlacementProxy, x:number, y:number)
---@field get fun(self:PlacementProxy):Point
PlacementProxy = {}

---@class VelocityProxy
---@field set fun(self:VelocityProxy, x:number, y:number)
---@field get fun(self:VelocityProxy):Vector2D
---@field x number
---@field y number
VelocityProxy = {}

---@class KeyValue
---@field get fun(self:KeyValue, key:string, default:any):any
---@field set fun(self:KeyValue, key:string, new_value:any)
---@field subscribe fun(self:KeyValue, key:string, callback:fun(value:any))
KeyValue = {}

---@class Object
---@field id number
---@field x number
---@field y number
---@field alpha number
---@field scale number
---@field hide fun(self:Object)
---@field move fun(self:Object, x:number, y:number)
---@field on_update fun(self:Object, callback:fun(delta:number))
---@field on_animationfinished fun(self:Object, callback:fun())
---@field on_mail fun(self:Object, callback:fun(mail:Mail))
---@field on_touch fun(self:Object, callback:fun(x:number, y:number))
---@field on_motion fun(self:Object, callback:fun(x:number, y:number))
---@field on_hover fun(self:Object, callback:fun())
---@field on_unhover fun(self:Object, callback:fun())
---@field on_collision fun(self:Object, callback:fun(other:Object))
---@field on_nthtick fun(self:Object, callback:fun(n:number))
---@field reflection ReflectionProxy
---@field action ActionProxy
---@field placement PlacementProxy
---@field velocity VelocityProxy
---@field kv KeyValue
Object = {}

---@class ObjectManager
---@field create fun(self:ObjectManager, ...):Object
---@field clone fun(self:ObjectManager, obj:Object):Object
---@field destroy fun(self:ObjectManager, obj:Object)
ObjectManager = {}

---@class ResourceManager
---@field flush fun(self:ResourceManager)
---@field prefetch fun(self:ResourceManager, ...:string|table):void
ResourceManager = {}

---@class PlayerWrapper
---@field on fun(self:PlayerWrapper, type:number):boolean
PlayerWrapper = {}

---@class StateManager
---@field collides fun(self:StateManager, id:number, type:number):boolean
---@field players table<number,PlayerWrapper>
---@field player fun(self:StateManager, player:Player):PlayerWrapper
StateManager = {}

---@class SceneManager
---@field set fun(self:SceneManager, name:string)
---@field destroy fun(self:SceneManager, name:string)
---@field register fun(self:SceneManager, name:string)
SceneManager = {}

---@class CursorProxy
---@field set fun(self:CursorProxy, name:string)
---@field hide fun(self:CursorProxy)
CursorProxy = {}

---@class Overlay
---@field create fun(self:Overlay, type:WidgetType):Label
---@field destroy fun(self:Overlay, widget:Widget)
---@overload fun(self:Overlay, event:string, ...:any)
---@field dispatch fun(self:Overlay, widgetType:WidgetType, event:string, ...:any)
---@field cursor CursorProxy
Overlay = {}

---@class Engine
---@field canvas fun(self:Engine):Canvas
---@field cassette fun(self:Engine):Cassette
---@field objectmanager fun(self:Engine):ObjectManager
---@field fontfactory fun(self:Engine):FontFactory
---@field overlay fun(self:Engine):Overlay
---@field resourcemanager fun(self:Engine):ResourceManager
---@field soundmanager fun(self:Engine):SoundManager
---@field statemanager fun(self:Engine):StateManager
---@field scenemanager fun(self:Engine):SceneManager
---@field timermanager fun(self:Engine):TimerManager
---@field run fun(self:Engine)
Engine = {}

---@class EngineFactory
---@field with_title fun(self:EngineFactory, title:string):EngineFactory
---@field with_width fun(self:EngineFactory, width:number):EngineFactory
---@field with_height fun(self:EngineFactory, height:number):EngineFactory
---@field with_scale fun(self:EngineFactory, scale:number):EngineFactory
---@field with_gravity fun(self:EngineFactory, x:number, y:number):EngineFactory
---@field with_fullscreen fun(self:EngineFactory, fullscreen:boolean):EngineFactory
---@field create fun(self:EngineFactory):Engine
---@field new fun(...):EngineFactory
EngineFactory = {}

---@class Font
Font = {}

---@class FontFactory
---@field get fun(self:FontFactory, name:string):Font
FontFactory = {}

---@class Canvas
---@field pixels table<number,number>
Canvas = {}

---@class Point
---@field x number
---@field y number
---@field set fun(self:Point, x:number, y:number)
Point = {}

---@class Size
---@field width number
---@field height number
Size = {}

---@class Widget
Widget = {}

---@class Label:Widget
---@field font Font
---@field set fun(self:Label, text:string, size?:number, alignment?:number)
---@field clear fun(self:Label)
Label = {}

---@class Cassette
---@field clear fun(self:Cassette)
---@field set fun(self:Cassette, key:string, value:any)
---@field get fun(self:Cassette, key:string, default:any):any
Cassette = {}

---@class Socket
---@field connect fun(self:Socket, address:string):boolean
---@field emit fun(self:Socket, event:string, data:table)
---@field on fun(self:Socket, event:string, callback:fun(data:table))
---@field rpc fun(self:Socket, method:string, args:table, callback:fun(response:table))
Socket = {}

---@class Color
---@field r number
---@field g number
---@field b number
---@field a number
Color = {}

---@class Mail
---@field new fun(sender:Object, receiver?:Object, message:string):Mail
Mail = {}

---@class PostalService
---@field post fun(self:PostalService, mail:Mail)
---@field new fun():PostalService
PostalService = {}

---@class TimerManager
---@field set fun(self:TimerManager, interval:number, callback:fun())
---@field singleshot fun(self:TimerManager, delay:number, callback:fun())
---@field clear fun(self:TimerManager, id:number)
TimerManager = {}

---@class Vector2D
---@field x number
---@field y number
---@field set fun(self:Vector2D, x:number, y:number)
---@field magnitude fun(self:Vector2D):number
---@field unit fun(self:Vector2D):Vector2D
---@field dot fun(self:Vector2D, other:Vector2D):number
---@field add_assign fun(self:Vector2D, other:Vector2D)
---@field sub_assign fun(self:Vector2D, other:Vector2D)
---@field mul_assign fun(self:Vector2D, scalar:number)
---@field div_assign fun(self:Vector2D, scalar:number)
---@field zero fun():Vector2D
---@field moving fun():Vector2D
---@field right fun():Vector2D
---@field left fun():Vector2D
Vector2D = {}
