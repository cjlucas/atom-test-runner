module Range exposing
    ( Range
    , precise
    , row
    , toPrimative
    )

import Point exposing (Point)


type Range
    = RowRange Int
    | PreciseRange Point Point


type alias PrimativeRange =
    { row : Maybe Int
    , precise : Maybe ( Point, Point )
    }


row num =
    RowRange num


precise start end =
    PreciseRange start end


toPrimative range =
    case range of
        RowRange row ->
            { row = Just row
            , precise = Nothing
            }

        PreciseRange start end ->
            { row = Nothing
            , precise = Just ( start, end )
            }
