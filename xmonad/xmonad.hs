{-# LANGUAGE DeriveDataTypeable    #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeSynonymInstances  #-}

import           Control.Monad                          (forM_, join, when)
import           Data.List
import qualified Data.Map                               as M
import           Data.Maybe                             (fromMaybe, maybeToList)
import           Data.Monoid                            ()
import           System.Exit
import           System.IO
import           XMonad                                 hiding ((|||))
import           XMonad.Actions.AfterDrag
import           XMonad.Actions.CycleWS
import qualified XMonad.Actions.FlexibleManipulate      as Flex
import           XMonad.Actions.LinkWorkspaces
import           XMonad.Actions.Minimize
import           XMonad.Actions.Navigation2D
import           XMonad.Actions.WithAll
import           XMonad.Hooks.CurrentWorkspaceOnTop
import           XMonad.Hooks.EwmhDesktops              (ewmh, ewmhDesktopsEventHook,
                                                         ewmhDesktopsLogHook)
import           XMonad.Hooks.ManageDocks               (Direction2D (D, L, R, U),
                                                         ToggleStruts (..), avoidStruts, docks,
                                                         manageDocks)
import           XMonad.Hooks.ManageHelpers             (doCenterFloat, doFloatAt, doFullFloat,
                                                         isDialog, isFullscreen, transience')
import           XMonad.Hooks.Minimize
import           XMonad.Hooks.RefocusLast
import qualified XMonad.Layout.BoringWindows            as BW
import           XMonad.Layout.ButtonDecoration
import           XMonad.Layout.Decoration
import           XMonad.Layout.DecorationAddons
import           XMonad.Layout.DraggingVisualizer
import           XMonad.Layout.Fullscreen               (fullscreenEventHook, fullscreenFull,
                                                         fullscreenManageHook, fullscreenSupport)
import           XMonad.Layout.Grid
import           XMonad.Layout.Groups.Wmii
import           XMonad.Layout.ImageButtonDecoration
import           XMonad.Layout.LayoutCombinators
import           XMonad.Layout.LimitWindows
import           XMonad.Layout.Minimize
import           XMonad.Layout.MultiToggle
import           XMonad.Layout.NoBorders
import           XMonad.Layout.SimpleDecoration
import           XMonad.Layout.Simplest
import           XMonad.Layout.Spacing                  (Border (Border), SpacingModifier (..),
                                                         spacingRaw, toggleScreenSpacingEnabled,
                                                         toggleWindowSpacingEnabled)
import           XMonad.Layout.SubLayouts
import           XMonad.Layout.Tabbed
import           XMonad.Layout.TrackFloating
import           XMonad.Layout.WindowNavigation
import           XMonad.Layout.WindowSwitcherDecoration
import           XMonad.Prompt
import           XMonad.Prompt.Window
import qualified XMonad.StackSet                        as W
import           XMonad.Util.NamedWindows               (getName)
import           XMonad.Util.Run                        (safeSpawn, spawnPipe)
import           XMonad.Util.SpawnOnce                  (spawnOnce)

myTerminal = "alacritty"

myFocusFollowsMouse = False

myClickJustFocuses = False

myBorderWidth = 1

myModMask = mod1Mask

myWorkspaces = ["1", "2", "3", "4", "5", "6", "7", "8", "9"]

myNormalBorderColor = "#5f5f87"

myFocusedBorderColor = "#d787ff"

addNETSupported :: Atom -> X ()
addNETSupported x = withDisplay $ \dpy -> do
  r <- asks theRoot
  a_NET_SUPPORTED <- getAtom "_NET_SUPPORTED"
  a <- getAtom "ATOM"
  liftIO $ do
    sup <- join . maybeToList <$> getWindowProperty32 dpy a_NET_SUPPORTED r
    when (fromIntegral x `notElem` sup) $
      changeProperty32 dpy r a_NET_SUPPORTED a propModeAppend [fromIntegral x]

addEWMHFullscreen :: X ()
addEWMHFullscreen = do
  wms <- getAtom "_NET_WM_STATE"
  wfs <- getAtom "_NET_WM_STATE_FULLSCREEN"
  mapM_ addNETSupported [wms, wfs]

-- Alt is for focus, layout, workspace and program control
-- Win is for window control (position, size, occupied workspace)
myKeys conf@XConfig {XMonad.modMask = modm} =
  M.fromList $
    -- Programs
    [ ((mod4Mask, xK_l), spawn "slock"),
      ((modm, xK_Return), spawn myTerminal),
      ((modm, xK_space), spawn "rofi -show run"),
      ((0, xK_Print), spawn "spectacle -bmc -o ~/Pictures/$(date +%Y-%m-%d_%H-%M-%S).png"),
      ((controlMask, xK_Print), spawn "spectacle -brc -o ~/Pictures/$(date +%Y-%m-%d_%H-%M-%S).png"),
      ((modm, xK_backslash), kill),
      ((modm .|. controlMask, xK_backslash), killAll),
      ((modm .|. shiftMask, xK_p), io exitSuccess),
      ((modm, xK_p), spawn "if type xmonad; then xmonad --recompile && xmonad --restart; else xmessage xmonad not in \\$PATH: \"$PATH\"; fi"),
      ((modm, xK_n), spawn "kill -s USR1 $(pidof deadd-notification-center)"),
      -- Layouts
      ((modm, xK_q), sendMessage $ JumpToLayout "Tall"),
      ((modm, xK_w), sendMessage $ JumpToLayout "Full"),
      ((modm, xK_e), sendMessage $ JumpToLayout "Grid"),
      -- Mini/Maximize
      ((modm, xK_m), withFocused minimizeWindow),
      ((modm .|. controlMask, xK_m), withLastMinimized maximizeWindowAndFocus),
      -- Toggles
      ((modm, xK_Super_L), sendMessage $ Toggle DECORATIONS),
      ((modm, xK_o), toggleWindowSpacingEnabled <+> toggleScreenSpacingEnabled),
      ((modm, xK_y), sendMessage ToggleStruts),
      -- Directional navigation of windows
      ((modm, xK_l), windowGo R True),
      ((modm, xK_h), windowGo L True),
      ((modm, xK_k), windowGo U True),
      ((modm, xK_j), windowGo D True),
      -- Swap adjacent windows
      ((mod4Mask, xK_l), withFocused (\w -> swapOrSend w R)),
      ((mod4Mask, xK_h), withFocused (\w -> swapOrSend w L)),
      ((mod4Mask, xK_k), windowSwap U True),
      ((mod4Mask, xK_j), windowSwap D True),
      -- Directional navigation of screens
      ((modm, xK_Right), screenGo R True),
      ((modm, xK_Left), screenGo L True),
      -- Swap workspaces on adjacent screens
      ((mod4Mask, xK_Tab), screenSwap R True),
      ((mod4Mask .|. shiftMask, xK_Tab), screenSwap L True),
      -- Inc/Dec window limit
      ((modm, xK_equal), setLimit 4),
      ((modm .|. shiftMask, xK_equal), increaseLimit),
      ((modm, xK_minus), decreaseLimit),
      -- Cycle workspaces
      ((modm .|. controlMask, xK_Right), nextWS),
      ((modm .|. controlMask, xK_Left), prevWS),
      ((modm .|. mod4Mask, xK_Right), shiftToNext >> nextWS),
      ((modm .|. mod4Mask, xK_Left), shiftToPrev >> prevWS),
      -- SubLayouts
      ((modm .|. controlMask, xK_h), sendMessage $ pullGroup L),
      ((modm .|. controlMask, xK_l), sendMessage $ pullGroup R),
      ((modm .|. controlMask, xK_k), sendMessage $ pullGroup U),
      ((modm .|. controlMask, xK_j), sendMessage $ pullGroup D),
      ((modm .|. controlMask, xK_period), withFocused (sendMessage . MergeAll)),
      ((modm .|. controlMask, xK_comma), withFocused (sendMessage . UnMerge)),
      ((modm, xK_b), toSubl NextLayout),
      ((modm, xK_Tab), BW.focusUp),
      ((modm .|. shiftMask, xK_Tab), BW.focusDown),
      -- Linked workspaces
      ((modm, xK_i), toggleLinkWorkspaces defaultMessageConf),
      ((modm .|. controlMask, xK_i), removeAllMatchings defaultMessageConf)
    ]
      ++ [ ((mod4Mask, k), windows $ W.shift i)
           | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
         ]
      ++ [ ((modm .|. m, k), a i)
           | (a, m) <- [(switchWS (windows . W.greedyView) defaultMessageConf, 0), (switchWS (\x -> windows $ W.shift x . W.greedyView x) defaultMessageConf, shiftMask)],
             (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
         ]

swapOrSend w dir = do
    r <- windowRect w
    case r of
      Nothing -> return ()
      Just wr ->
        if isOnEdge dir wr
          then windowToScreen dir False <+> screenGo dir False
          else windowSwap dir False
    where
        isOnEdge dir wr = case dir of
                         R -> (rect_x wr + fromIntegral (rect_width wr)) == 1900
                         L -> rect_x wr == 1940


windowRect :: Window -> X (Maybe Rectangle)
windowRect win = withDisplay $ \dpy -> do
  mp <- isMapped win
  if mp
    then
      do
        (_, x, y, w, h, bw, _) <- io $ getGeometry dpy win
        return $ Just $ Rectangle x y (w + 2 * bw) (h + 2 * bw)
        `catchX` return Nothing
    else return Nothing

isMapped win = withDisplay $
  \dpy ->
    io $
      (waIsUnmapped /=)
        . wa_map_state
        <$> getWindowAttributes dpy win

myMouseBindings XConfig {XMonad.modMask = modm} =
            M.fromList
    [ ((modm, button3), \w -> focus w >> Flex.mouseWindow Flex.resize w >> ifClick (withFocused $ windows . W.sink)),
      ((modm, button2), \w -> focus w >> withFocused killWindow),
      ((modm, button1), \w -> focus w >> Flex.mouseWindow Flex.position w),
      ((button1Mask, button3), \w -> focus w >> mouseMoveWindow w >> windows W.shiftMaster)
    ]

myAppendFile :: FilePath -> String -> IO ()
myAppendFile f s = do
  withFile f AppendMode $ \h -> do
    hPutStrLn h s

logToTmpFile :: String -> IO ()
logToTmpFile = myAppendFile "/tmp/xmonad.log" . (++ "\n")

data DECORATIONS = DECORATIONS deriving (Read, Show, Eq, Typeable)

instance Transformer DECORATIONS Window where
  transform _ x k = k (windowSwitcherDecorationWithImageButtons shrinkText myTheme x) (\(ModifiedLayout _ x') -> x')

myTheme =
  defaultThemeWithImageButtons
    { activeColor = "#d787ff",
      inactiveColor = "#5f5f87",
      activeBorderWidth = 0,
      inactiveBorderWidth = 0,
      activeTextColor = "#080808",
      inactiveTextColor = "#080808",
      fontName = "-monotype-noto serif-medium-r-normal--0-0-0-0-p-0-microsoft-cp1252"
    }

myNavigation2DConfig =
  def
    { defaultTiledNavigation = centerNavigation,
      layoutNavigation = [("Full", centerNavigation)],
      unmappedWindowRect = [("Full", singleWindowRect)]
    }

myLayout =
    lessBorders Never $
  avoidStruts $
      limitWindows 4 $
    refocusLastLayoutHook . trackFloating $
      mkToggle (single DECORATIONS) $
        draggingVisualizer $
          spacingRaw True (Border 10 10 10 10) True (Border 10 10 10 10) True $
            minimize $
              BW.boringWindows $
                  trackFloating
                      (tiled ||| noBorders Full ||| Grid)
  where
    tiled = Tall nmaster delta ratio
    nmaster = 1
    ratio = 1 / 2
    delta = 3 / 100

myManageHook =
  fullscreenManageHook <+> manageDocks
    <+> composeAll
      [ className =? "MPlayer" --> doFloat,
        className =? "Gimp" --> doFloat,
        className =? "RAIL" --> doFloat,
        className =? "Microsoft Word" --> doFloat,
        resource =? "desktop_window" --> doIgnore,
        resource =? "kdesktop" --> doIgnore,
        isDialog --> doCenterFloat,
        isFullscreen --> doFullFloat,
        transience'
      ]

myStartupHook = do
  spawnOnce "taffybar"
  spawnOnce "feh --bg-scale ~/pics/wall.png"
  spawnOnce "picom -b --config ~/.config/picom/picom.conf"
  spawnOnce "deadd-notification-center"

myEvHook = mconcat [ewmhDesktopsEventHook, minimizeEventHook]

myEventHook = refocusLastEventHook <+> myEvHook
  where
    refocusLastEventHook = refocusLastWhen isFloat

main = do
  xmonad $
    withNavigation2DConfig myNavigation2DConfig $
      fullscreenSupport $
        docks $
          ewmh $
            def
              { terminal = myTerminal,
                focusFollowsMouse = myFocusFollowsMouse,
                clickJustFocuses = myClickJustFocuses,
                borderWidth = myBorderWidth,
                modMask = myModMask,
                workspaces = myWorkspaces,
                normalBorderColor = myNormalBorderColor,
                focusedBorderColor = myFocusedBorderColor,
                keys = \c -> myKeys c `M.union` keys XMonad.def c,
                -- mouseBindings = \c -> myMouseBindings c `M.union` mouseBindings XMonad.def c,
                mouseBindings = myMouseBindings,
                manageHook = myManageHook,
                layoutHook = myLayout,
                handleEventHook = myEventHook,
                startupHook = myStartupHook >> addEWMHFullscreen,
                logHook = currentWorkspaceOnTop
              }
