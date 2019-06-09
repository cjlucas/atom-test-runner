module Point exposing (Point, at)


type alias Point =
    { row : Int, col : Int }


at row col =
    Point row col
