import XMonad
import qualified XMonad.Layout.Renamed as Renamed
import XMonad.Actions.MouseResize
import XMonad.Layout.NoFrillsDecoration
import XMonad.Layout.WindowArranger
import XMonad.Layout.ResizableTile
import XMonad.Layout.BoringWindows
import XMonad.Layout.SubLayouts
import XMonad.Layout.WindowNavigation
import XMonad.Config.Desktop
import XMonad.Util.SpawnOnce
import XMonad.Actions.FloatSnap
import XMonad.Layout.Spacing ( spacingRaw, Border(Border) )
import XMonad.Hooks.EwmhDesktops (ewmh, fullscreenEventHook)
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.ManageDocks
    ( avoidStruts, docks, manageDocks, Direction2D(D, L, R, U) )
import XMonad.Layout.NoBorders
import XMonad.Util.Cursor (setDefaultCursor, xC_left_ptr)
import qualified XMonad.Layout.Fullscreen as FS
import XMonad.Layout.Gaps
    ( Direction2D(D, L, R, U),
      gaps,
      setGaps,
      GapMessage(DecGap, ToggleGaps, IncGap) )
import XMonad.Hooks.EwmhDesktops (ewmh, fullscreenEventHook)
import XMonad.Actions.CycleWS
import qualified XMonad.StackSet as W

import qualified Data.Map as M
import Data.List

myTerminal = "alacritty"

myFocusFollowsMouse = False

myClickJustFocuses = False

myModMask = mod1Mask 

myStartupHook = do
  spawnOnce "$HOME/.config/polybar/launch.sh"
  spawnOnce "feh --bg-scale /home/hy/pics/wall.png"

myWorkspaces =  ["main", "help", "back", "4", "5", "6", "7", "8", "9"]

myNormalBorderColor = "#5f5f87"

myFocusedBorderColor = "#d787ff"

maimsave = spawn "maim | feh --keep-zoom-vp & maim -s ~/pics/$(date +%Y-%m-%d_%H-%M-%S).png"

myLayout = avoidStruts 
		 -- $ mouseResize
		 -- $ windowArrange
		 $ spacingRaw True (Border 10 10 10 10) False (Border 10 10 10 10) True 
		 $ (tiled ||| noBorders Full)
  where
     tiled   = Tall nmaster delta ratio
     nmaster = 1
     ratio   = 1/2
     delta   = 3/100

myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $
  [((0, xK_Print), maimsave)
  , ((mod4Mask, xK_l), (spawn "slock"))
  , ((mod1Mask, xK_Return), (spawn myTerminal))
  , ((mod1Mask, xK_backslash), kill)
  , ((modm .|. controlMask              , xK_s    ), sendMessage  Arrange         )
  , ((modm .|. controlMask .|. shiftMask, xK_s    ), sendMessage  DeArrange      )
  , ((modm .|. controlMask              , xK_Left ), sendMessage (MoveLeft      40))
  , ((modm .|. controlMask              , xK_Right), sendMessage (MoveRight     40))
  , ((modm .|. controlMask              , xK_Down ), sendMessage (MoveDown      40))
  , ((modm .|. controlMask              , xK_Up   ), sendMessage (MoveUp        40))
  , ((modm                 .|. shiftMask, xK_Left ), sendMessage (IncreaseLeft  40))
  , ((modm                 .|. shiftMask, xK_Right), sendMessage (IncreaseRight 40))
  , ((modm                 .|. shiftMask, xK_Down ), sendMessage (IncreaseDown  40))
  , ((modm                 .|. shiftMask, xK_Up   ), sendMessage (IncreaseUp    40))
  , ((modm .|. controlMask .|. shiftMask, xK_Left ), sendMessage (DecreaseLeft  40))
  , ((modm .|. controlMask .|. shiftMask, xK_Right), sendMessage (DecreaseRight 40))
  , ((modm .|. controlMask .|. shiftMask, xK_Down ), sendMessage (DecreaseDown  40))
  , ((modm .|. controlMask .|. shiftMask, xK_Up   ), sendMessage (DecreaseUp    40))
  ]
  ++
  [((mod4Mask, k), windows $ W.shift i)
    | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
  ]

myMouseBindings (XConfig {XMonad.modMask = modm}) = M.fromList $
	[ ((modm,               button1), (\w -> focus w >> mouseMoveWindow w >> ifClick (snapMagicMove (Just 50) (Just 50) w)))
       , ((modm .|. shiftMask, button1), (\w -> focus w >> mouseMoveWindow w >> ifClick (snapMagicResize [L,R,U,D] (Just 50) (Just 50) w)))
       , ((modm,               button3), (\w -> focus w >> mouseResizeWindow w >> ifClick (snapMagicResize [R,D] (Just 50) (Just 50) w)))
	]

myManageHook = composeAll
    [ className =? "Gimp"           --> doFloat
    , className =? "transmission-gtk" --> doFloat
    , className =? "mpv" --> doFloat
    , resource  =? "desktop_window" --> doIgnore
    , resource  =? "kdesktop"       --> doIgnore
    , fmap (isInfixOf "display") appCommand --> doFloat
    , (stringProperty "WM_WINDOW_ROLE" =? "GtkFileChooserDialog") --> doFullFloat
    , isFullscreen                  --> doFullFloat
    , FS.fullscreenManageHook
    ]
	where
		appCommand = stringProperty "WM_COMMAND"

main = do
    xmonad $ desktopConfig {
        terminal           = myTerminal,
        focusFollowsMouse  = myFocusFollowsMouse,
        clickJustFocuses   = myClickJustFocuses,
        borderWidth        = 1,
        modMask            = myModMask,
		workspaces		   = myWorkspaces,
        mouseBindings      = myMouseBindings,
		normalBorderColor  = myNormalBorderColor,
		focusedBorderColor = myFocusedBorderColor,
        keys               = \c -> myKeys c `M.union` keys XMonad.def c,
		layoutHook         = myLayout,
		-- manageHook         = myManageHook <+> manageHook desktopConfig,
		-- handleEventHook    = fullscreenEventHook <+> handleEventHook desktopConfig,
	    startupHook        = myStartupHook <+> startupHook desktopConfig
    }

