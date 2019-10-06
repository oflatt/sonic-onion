module View exposing (view)

import Model exposing (..)
import DrawProgram exposing (drawProgram)
import DrawToolbar exposing (drawToolBar)

import Browser
import Css exposing (..)

import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (css, href, src, rel)
import Html.Styled.Events exposing (onClick, onMouseOver, onMouseLeave)
import Html.Attributes exposing (id)
import Svg
import Svg.Attributes



pageColor = (rgb 247 247 222)
pageBackgroundColor = (rgb 229 229 208)

scrollbarWidth = 40
titleHeight = 90
buttonHeight = 50
toolbarProportion = 0.25
               

view : Model -> Browser.Document Msg
view model =
    {title = "Sonic Onion"
    , body =
        [toUnstyled
             (div [ ]
                  [ node "link" [rel "stylesheet"
                                ,href "https://fonts.googleapis.com/css?family=Tangerine"][]
                  , node "link" [rel "stylesheet"
                                ,href "https://fonts.googleapis.com/css?family=Raleway"][]
                      
                  
                  ,(makeTitle)
                  
                  ,(pagebutton "Home" model)
                  ,(pagebutton "Listings" model)
                      
                  
                  ,(makePage "Home" (programPage model) model)
                      
                  
                  , (makePage "Listings" (listing "./assets/placeholder.png"
                                              "Listing title" model)
                         model)
                  ])]
    }
      
            
makePage pageName content model =
                if pageName == model.currentPage then
                    div [css[display block
                ,backgroundColor pageColor]]
            [content]
    else
        text ""
      
makeTitle = div
            [css [
             height (px titleHeight)
             ,width (pct 100)
                ]
               ]
            [div[css[
                  textAlign (center)
                 ,padding (px 20)
                 ]
                ]
                 [div[css[
                       fontFamilies ["Raleway"]
                      ,fontSize (px 32)
                      ,top (px 10)
                      ,display (inlineBlock)
                      ]]
                      [text "Title"]
                 ,div[css[
                       display (inlineBlock)
                      ]
                     ]
                     [
                      button [onClick (PlaySound)]
                      [text "Play"]
                          ]
                 ]]
                

pagebutton : PageName -> Model -> Html Msg
pagebutton pageName model =
    let buttonPageColor =
            if pageName == model.currentPage
            then pageColor
            else pageBackgroundColor
    in
    button [
         onClick (PageChange pageName)
        ,onMouseOver (MouseOver pageName)
        ,onMouseLeave (MouseLeave pageName)
        ,css
             [width (pct 20)
             ,height (px buttonHeight)
             ,marginTop (px 10)
             ,marginRight (px 10)
             ,borderTopLeftRadius (px 8)
             ,borderTopRightRadius (px 8)
             ,if pageName == model.highlightedButton
              then border (px 2)
              else border (px 0)
             ,borderColor (rgb 0 0 0)
             ,borderBottomColor buttonPageColor
             ,outline none
             ,borderStyle solid
             ,backgroundColor buttonPageColor
             ,fontFamilies ["Raleway"]
             ,fontSize (px 20)
             ]]
    [text pageName]
        
        
pagedisplay pagename model = if model.currentPage == pagename then display block else display none
                                     
                                     
                                     
listing imgName title model =
    div []
        [img [src imgName
             , css [
                   left (pct 10)
                  ,bottom (px 10)
                  ,height (pct 50)
                  ]][]
         ,text title]


programPage : Model -> Html Msg
programPage model =
    let toolbarWidth =
            Basics.round (toolbarProportion * (toFloat model.windowWidth))
    in
        div [css[display (inlineBlock)]]
            [(drawToolBar
                  model
                  toolbarWidth
                  ((model.windowHeight-titleHeight)-buttonHeight))
            ,(drawProgram
                  model
                  (model.windowWidth-scrollbarWidth-toolbarWidth)
                  ((model.windowHeight-titleHeight)-buttonHeight))
            ]
