module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Url
import Route exposing (Route)
import Page.OhmLaw
import Page.Home
import Page.Blank



-- MAIN


main : Program () Model Msg
main =
  Browser.application
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    , onUrlChange = UrlChanged
    , onUrlRequest = LinkClicked
    }



-- MODEL

type PageModel
  = Home Page.Home.Model
  | OhmLaw Page.OhmLaw.Model
  | Redirect

type alias Model =
  { key : Nav.Key
  , pageModel : PageModel
  }


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
  changeRouteTo (Route.fromUrl url) key Redirect



-- UPDATE



type Msg
  = LinkClicked Browser.UrlRequest
  | UrlChanged Url.Url
  | GotOhmLaw Page.OhmLaw.Msg
  | GotHomeMsg Page.Home.Msg

changeRouteTo : Maybe Route -> Nav.Key -> PageModel -> ( Model, Cmd Msg )
changeRouteTo maybeRoute key pageModel =
  let model = { key = key, pageModel = pageModel }
  in case maybeRoute of
        Nothing ->
          ( model , Route.replaceUrl key Route.Home )
        Just Route.Root ->
          ( model , Route.replaceUrl key Route.Home )
        Just Route.Home ->
          Page.Home.init 
            |> updateWith Home GotHomeMsg model
        Just Route.OhmLaw ->
          Page.OhmLaw.init 
            |> updateWith OhmLaw GotOhmLaw model


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case ( msg, model.pageModel ) of
    ( LinkClicked urlRequest, _ ) ->
      case urlRequest of
        Browser.Internal url ->
          ( model, Nav.pushUrl model.key (Url.toString url) )

        Browser.External href ->
          ( model, Nav.load href )

    ( UrlChanged url, _ ) ->
      changeRouteTo (Route.fromUrl url) model.key model.pageModel

    ( GotHomeMsg _, Home _ ) ->
      Page.Home.init
       |> updateWith Home GotHomeMsg model

    ( GotOhmLaw subMsg, OhmLaw ohmLaw ) ->
      Page.OhmLaw.update subMsg ohmLaw
          |> updateWith OhmLaw GotOhmLaw model

    ( _, _ ) ->
      -- Disregard messages that arrived for the wrong page.
      (model, Cmd.none)


updateWith : (subModel -> PageModel) -> (subMsg -> Msg) -> Model -> ( subModel, Cmd subMsg ) -> ( Model, Cmd Msg )
updateWith toModel toMsg model ( subModel, subCmd ) =
    ( { model | pageModel = toModel subModel }
    , Cmd.map toMsg subCmd
    )

-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
  Sub.none



-- VIEW


view : Model -> Browser.Document Msg
view model =
  case model.pageModel of
    Redirect -> 
      viewPage Page.Blank.view

    Home _ ->
      let { title, body } = viewPage (Page.Home.view)
      in { title = title, body = List.map (Html.map GotHomeMsg) body }

    OhmLaw ohmLaw ->
      let { title, body } = viewPage (Page.OhmLaw.view ohmLaw)
      in { title = title, body = List.map (Html.map GotOhmLaw) body }
    


viewHeader : Html msg
viewHeader =
    nav [ class "navbar navbar-light" ]
        [ div [ class "container" ]
            [ a [ class "navbar-brand", Html.Attributes.href "/home" ] [ text "home" ]
            , a [ class "navbar-brand", Html.Attributes.href "/ohm-law" ] [ text "ohm-law" ]
            ]
        ]

{-| Take a page's Html and frames it with a header and footer.
The caller provides the current user, so we can display in either
"signed in" (rendering username) or "signed out" mode.
isLoading is for determining whether we should show a loading spinner
in the header. (This comes up during slow page transitions.)
-}
viewPage : { title : String, content : Html msg } -> Browser.Document msg
viewPage { title, content } =
    { title = title ++ " - VapeTool"
    , body = viewHeader :: content :: [ viewFooter ]
    }
    

viewFooter : Html msg
viewFooter =
    footer []
        [ div [ class "container" ]
            [ a [ class "logo-font", href "/" ] [ text "conduit" ]
            , span [ class "attribution" ]
                [ text "An interactive learning project from "
                , a [ href "https://thinkster.io" ] [ text "Thinkster" ]
                , text ". Code & design licensed under MIT."
                ]
            ]
        ]


viewLink : String -> Html msg
viewLink path =
  li [] [ a [ href path ] [ text path ] ]

