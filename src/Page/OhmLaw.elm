module Page.OhmLaw exposing (view, Model, Msg, init, update)

import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)

type alias Model =
    { lastEdit : Maybe Inputs
    , latestEdit : Maybe Inputs

    , voltage : String
    , power : String
    , current : String
    , resistance : String
    }
    
type Inputs 
  = Voltage 
  | Resistance 
  | Current 
  | Power




-- MODEL


init : ( Model, Cmd Msg )
init = ( emptyModel , Cmd.none )



-- VIEW



view : Model -> { title : String, content : Html Msg }
view model =
    { title = "Ohm Law"
    , content =
        div [ class "cred-page" ]
            [ div [ class "container page" ]
                [ div [ class "row" ]
                    [ div [ class "col-md-6 offset-md-3 col-xs-12" ]
                        [ h1 [ class "text-xs-center" ] [ text "Sign up" ]
                        , viewForm model
                        ]
                    ]
                ]
            ]
    }

viewForm : Model -> Html Msg
viewForm model =
    Html.form [ onSubmit ClickedCalculated ]
        [ fieldset [ class "form-group" ]
            [ input
                [ class "form-control form-control-lg"
                , type_ "number"
                , placeholder "Voltage"
                , onInput (Changed Voltage)
                , value model.voltage
                ]
                []
            ]

        , fieldset [ class "form-group" ]
            [ input
                [ class "form-control form-control-lg"
                , type_ "number"
                , placeholder "Resistance"
                , onInput (Changed Resistance) 
                , value model.resistance
                ]
                []
            ]

        , fieldset [ class "form-group" ]
            [ input
                [ class "form-control form-control-lg"
                , type_ "number"
                , placeholder "Current"
                , onInput (Changed Current)
                , value model.current
                ]
                []
            ]

        , fieldset [ class "form-group" ]
            [ input
                [ class "form-control form-control-lg"
                , type_ "number"
                , placeholder "Power"
                , onInput (Changed Power)
                , value model.power
                ]
                []
            ]

        , button [ onClick ClickedCalculated ] [ text "Calculate"  ]
        ]


viewInput : String -> (String -> msg) -> Html msg
viewInput v toMsg =
  input [ type_ "number", value v, onInput toMsg ] []



-- UPDATE


type Msg
    = Changed Inputs String
    | Clean
    | ClickedCalculated


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
      ClickedCalculated -> (calculate model, Cmd.none)
      Clean -> ( 
        { model | power = ""
        , current = ""
        , voltage = ""
        , resistance = ""
        , lastEdit = Nothing
        , latestEdit = Nothing }, Cmd.none )
      Changed what newValue ->
        let newModel = updateLasts what (updateField model what newValue)
        in (newModel, Cmd.none)

-- Internals



emptyModel : Model
emptyModel = 
  { power = ""
  , current = ""
  , voltage = ""
  , resistance = ""
  , lastEdit = Nothing
  , latestEdit = Nothing
  }


updateField : Model -> Inputs -> String -> Model
updateField model what newValue = 
  case what of 
    Voltage -> { model | voltage = newValue }
    Resistance -> { model | resistance = newValue }
    Current -> { model | current = newValue }
    Power -> { model | power = newValue }

updateLasts : Inputs -> Model -> Model
updateLasts newValue model = 
  let updated = { model | lastEdit = Just newValue, latestEdit = model.lastEdit }
  in case model.lastEdit of 
                Just lastEdit ->
                  if newValue == lastEdit 
                  then model
                  else updated
                Nothing -> updated

-- TODO(gbaranski) peruse https://github.com/vape-tool/VapeTool-Webapp/blob/master/src/models/ohm.ts#L44
calculate : Model -> Model
calculate model = (model)

