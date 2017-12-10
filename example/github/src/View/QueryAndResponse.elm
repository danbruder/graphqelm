module View.QueryAndResponse exposing (view)

import Graphqelm.Document as Document exposing (RootField)
import Html exposing (div, h1, p, pre, text)


view : RootField a -> model -> Html.Html msg
view query model =
    div []
        [ div []
            [ h1 [] [ text "Generated Query" ]
            , pre [] [ text (Document.toQuery query) ]
            ]
        , div []
            [ h1 [] [ text "Response" ]
            , Html.text (toString model)
            ]
        ]
