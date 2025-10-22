local dsn = "https://2166e6a109084188b05b0c9e9d7412e4@o4509972952907776.ingest.us.sentry.io/4509972956708864"

_G.engine = EngineFactory.new()
  :with_title("Reprobate")
  :with_width(1920)
  :with_height(1080)
  :with_scale(4.0)
  :with_fullscreen(true)
  :with_sentry(dsn)
  :create()

function setup()
  overlay.cursor:set("horn")

  local scene = queryparam("scene", "prelude")

  scenemanager:register(scene)

  scenemanager:set(scene)
end

function loop() end
