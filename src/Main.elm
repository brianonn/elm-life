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
import Html exposing (Html, div, button, text)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)
import Array exposing (Array)
import Time exposing (Posix)
import Random

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
    }

type Msg
    = Tick
    | Step
    | NewRandomGrid Grid
    | Restart

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
-- You can switch to manual stepping by removing this and wiring a button.)
subscriptions : Model -> Sub Msg
subscriptions _ =
    Time.every 300 (\_ -> Tick)

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

        Step ->
            ( { model | grid = nextGen model, generation = model.generation + 1 }, Cmd.none )

        Restart ->
            ( { model | generation = 1 }, generateRandomGrid model.width model.height )

-- view function
-- This renders the grid as a series of divs with CSS-based "pixels" and a manual "Step" button
view : Model -> Html Msg
view model =
    div []
        [ div []
            (Array.toList model.grid
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
        , div [] [ button [ onClick Step ] [ text "Step" ]
                 , button [ onClick Restart ] [ text "Restart" ]
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

