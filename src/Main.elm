-- Building:
--   $ elm make src/main.elm --output=main.js
-- or simply
--   $ make
--
-- Running:
--     Mac: $ open index.html
--   Linux: $ xdg-open index.html

module Main exposing (..)

import Browser
import Html exposing (Html, div, button, text, input)
import Html.Attributes exposing (type_, style, disabled, min, max, step, value)
import Html.Events exposing (onClick, onInput)
import Array exposing (Array)
import Time exposing (Posix)
import Random
import String exposing (toInt)

-- types
type alias Cell =
    Bool -- True = alive, False = dead

type alias Grid =
    Array (Array Cell)

type alias Model =
    { grid : Grid
    , width : Int
    , height : Int
    , generation : Int
    , running : Bool
    , tickInterval : Int -- milliseconds
    }

type Msg
    = NewRandomGrid Grid
    | Tick
    | SetTickInterval Int
    | Step
    | ToggleRunning
    | Reset


-- constants
width : Int
width = 120

height : Int
height = 120

initialModel : Model
initialModel =
    { grid = Array.empty
    , width = width
    , height = height
    , generation = 1
    , running = False
    , tickInterval = 300
    }

cellSize : Int
cellSize = 5

cellSizePx : String
cellSizePx = String.fromInt cellSize ++ "px"

-- initialization
randomGrid : Int -> Int -> Random.Generator Grid
randomGrid w h =
    let
        cellGen : Random.Generator Cell
        cellGen = Random.int 0 1 |> Random.map (\n -> n == 1)  -- True (alive) or False (dead)

        rowGen : Random.Generator (Array Cell)
        rowGen = Random.list w cellGen |> Random.map Array.fromList
    in
    Random.list h rowGen |> Random.map Array.fromList

generateRandomGrid : Int -> Int -> Cmd Msg
generateRandomGrid w h =
    Random.generate NewRandomGrid (randomGrid w h)

init : () -> ( Model, Cmd Msg )
init _ = ( initialModel, generateRandomGrid width height )

-- subscriptions (for animations)
subscriptions : Model -> Sub Msg
subscriptions model =
    if model.running then
        Time.every (toFloat model.tickInterval) (\_ -> Tick)
    else
        Sub.none

-- logic
nextGen : Model -> Grid
nextGen model =
    let
        get : Int -> Int -> Cell
        get x y =
            case Array.get y model.grid of
                Just row ->
                    case Array.get x row of
                        Just c -> c
                        Nothing -> False
                Nothing -> False

        neighbors x y =
            [ (x-1, y-1), (x, y-1), (x+1, y-1)
            , (x-1, y),           (x+1, y)
            , (x-1, y+1), (x, y+1), (x+1, y+1)
            ]
                |> List.map (\(nx, ny) -> get nx ny)
                |> List.filter identity
                |> List.length

        updateCell x y =
            let
                alive = get x y
                count = neighbors x y
            in
            (alive && (count == 2 || count == 3)) || (not alive && count == 3)
    in
    Array.initialize model.height (\y ->
        Array.initialize model.width (\x ->
            updateCell x y
        )
    )

-- update function
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NewRandomGrid grid ->
            ( { model | grid = grid }, Cmd.none )

        Tick ->
            ( { model | grid = nextGen model, generation = model.generation + 1 }, Cmd.none )

        SetTickInterval newInterval ->
            ( { model | tickInterval = newInterval }, Cmd.none )

        Step ->
            if model.running then
                ( model, Cmd.none ) -- step is a NOP when auto-running
            else
                ( { model | grid = nextGen model, generation = model.generation + 1 }, Cmd.none )

        ToggleRunning ->
            ( { model | running = not model.running }, Cmd.none )

        Reset ->
            ( { model | generation = 1 }, generateRandomGrid model.width model.height )

-- view functions
-- This renders the grid as a series of divs with CSS-based "pixels" and a manual "Step" button
styledButton : List (Html.Attribute msg) -> List (Html msg) -> Html msg
styledButton attrs children =
    let buttonStyle =
            [ style "margin-left" "10px"
            , style "margin-top" "2px"
            , style "margin-bottom" "2px"
            ]
    in
    button ( attrs ++ buttonStyle ) children

renderGrid : Grid -> Html msg
renderGrid grid =
    div []
        (Array.toList grid
            |> List.indexedMap (\y row ->
                div [ style "display" "flex" ]
                    (Array.toList row
                        |> List.indexedMap (\x cell ->
                            div
                                [ style "width" cellSizePx
                                , style "height" cellSizePx
                                , style "background-color" (if cell then "black" else "white")
                                , style "border" "1px solid #ccc"
                                ]
                                []
                        )
                )
            )
        )

renderSlider : Int -> Int -> Int -> Int -> Html Msg
renderSlider min_ max_ step_ value_ =
    let
        valueStr = String.fromInt value_
        minStr   = String.fromInt min_
        maxStr   = String.fromInt max_
        stepStr  = String.fromInt step_
    in
    div
        [ style "display" "inline-block"
        , style "margin-left" "20px"
        , style "vertical-align" "text-top"
        ]
        [ input
            [ type_ "range"
            , Html.Attributes.min minStr
            , Html.Attributes.max maxStr
            , step stepStr
            , value valueStr
            , onInput (\str -> SetTickInterval (Maybe.withDefault 300 (String.toInt str)))
            ]
            []
        , div [ style "margin-top" "-2px"] [ text ("Speed: " ++ valueStr ++ " ms") ]
        ]

view : Model -> Html Msg
view model =
    div []
        [ renderGrid model.grid
        , div []
            [ styledButton
                [ onClick ToggleRunning ]
                [ text (if model.running then "Stop" else "Start") ]
            , styledButton
                [ onClick Step, disabled model.running ]
                [ text "Step" ]
            , styledButton
                [ onClick Reset ]
                [ text (if model.running then "Restart" else "Reset") ]
            , renderSlider 50 2000 50 model.tickInterval
            ]
        , div [] [ text ("Generation: " ++ String.fromInt model.generation) ]

        ]

-- main entrypoint
main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }

