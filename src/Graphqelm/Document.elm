module Graphqelm.Document exposing (RootField, combine, decoder, queryField, toQuery)

import Graphqelm.Field as Field exposing (Field(Composite), FieldDecoder(FieldDecoder))
import Json.Decode as Decode exposing (Decoder)


type DocumentField
    = DocumentField MutationOrQuery Field


type MutationOrQuery
    = QueryField
    | MutationField


type RootField decodesTo
    = RootField (List DocumentField) (Decoder decodesTo)


queryField : FieldDecoder decodesTo lockedTo -> RootField decodesTo
queryField (FieldDecoder field decoder) =
    RootField [ DocumentField QueryField field ] decoder


separate : RootField decodesTo -> { queries : List Field, mutations : List Field }
separate (RootField documentFields decoder) =
    List.foldl
        (\(DocumentField mutationOrQuery field) soFar ->
            { soFar
                | queries =
                    case mutationOrQuery of
                        QueryField ->
                            soFar.queries ++ [ field ]

                        MutationField ->
                            soFar.mutations ++ [ field ]
            }
        )
        { queries = [], mutations = [] }
        documentFields


toQuery : RootField a -> String
toQuery document =
    document
        |> separate
        |> queriesString


queriesString : { document | queries : List Field } -> String
queriesString { queries } =
    if queries == [] then
        ""
    else
        "query {\n"
            ++ (List.indexedMap (\index query -> "query" ++ toString index ++ ": " ++ Field.fieldDecoderToQuery query) queries |> String.join "\n")
            ++ "\n}"


decoder : RootField decodesTo -> Decoder decodesTo
decoder (RootField fields decoder) =
    (case fields of
        [ DocumentField QueryField singleField ] ->
            Decode.field "query0" decoder

        [ DocumentField MutationField singleField ] ->
            Decode.field "mutation0" decoder

        multipleFields ->
            decoder
    )
        |> Decode.field "data"


combine : (decodesToA -> decodesToB -> decodesToC) -> RootField decodesToA -> RootField decodesToB -> RootField decodesToC
combine combineFunction (RootField fieldsA decoderA) (RootField fieldsB decoderB) =
    case ( fieldsA, fieldsB ) of
        ( [ singleA ], [ singleB ] ) ->
            RootField (fieldsA ++ fieldsB) (Decode.map2 combineFunction (Decode.field "query0" decoderA) (Decode.field "query1" decoderB))

        ( [ singleA ], multipleB ) ->
            RootField (fieldsB ++ fieldsA) (Decode.map2 combineFunction (Decode.field ("query" ++ toString (List.length fieldsB)) decoderA) decoderB)

        ( multipleA, [ singleB ] ) ->
            RootField (fieldsA ++ fieldsB) (Decode.map2 combineFunction decoderA (Decode.field ("query" ++ toString (List.length fieldsA)) decoderB))

        ( multipleA, multipleB ) ->
            RootField (fieldsA ++ fieldsB) (Decode.map2 combineFunction decoderA decoderB)
