{-# LANGUAGE OverloadedStrings #-}

import           System.Taffybar
import           System.Taffybar.Information.CPU
import           System.Taffybar.SimpleConfig
import           System.Taffybar.Widget
import           System.Taffybar.Widget.Generic.Graph
import           System.Taffybar.Widget.Generic.PollingGraph
import           System.Taffybar.Widget.SimpleCommandButton

main = do
  let
      cmdButton = simpleCommandButtonNew "test" "kill -s USR1 $(pidof deadd-notification-center)"
      clock = textClockNewWith defaultClockConfig { clockFormatString = "%d.%m.%Y %H:%M" }
      workspaces = workspacesNew defaultWorkspacesConfig
      simpleConfig = defaultSimpleTaffyConfig
                       { startWidgets = [ workspaces ]
                       , endWidgets = [ cmdButton, clock ]
                       , barPosition = Bottom
                       , barHeight = 40
                       }
  simpleTaffybar simpleConfig
