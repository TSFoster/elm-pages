module Pages.StaticHttpRequest exposing (Error(..), Request(..), errorToString, permanentError, resolve, resolveUrls, strippedResponses, toBuildError, urls)

import BuildError exposing (BuildError)
import Dict exposing (Dict)
import Pages.Internal.Secrets exposing (UrlWithSecrets)
import Secrets exposing (Secrets)
import TerminalText as Terminal


type Request value
    = Request ( List UrlWithSecrets, Dict String String -> Result Error ( Dict String String, Request value ) )
    | Done value


strippedResponses : Request value -> Dict String String -> Dict String String
strippedResponses request rawResponses =
    case request of
        Request ( list, lookupFn ) ->
            case lookupFn rawResponses of
                Err _ ->
                    Debug.todo ""

                Ok ( partiallyStrippedResponses, followupRequest ) ->
                    strippedResponses followupRequest partiallyStrippedResponses

        Done value ->
            rawResponses


errorToString : Error -> String
errorToString error =
    case error of
        MissingHttpResponse string ->
            string

        DecoderError string ->
            string


type Error
    = MissingHttpResponse String
    | DecoderError String


urls : Request value -> List UrlWithSecrets
urls request =
    case request of
        Request ( urlList, lookupFn ) ->
            urlList

        Done value ->
            []


toBuildError : String -> Error -> BuildError
toBuildError path error =
    { message =
        [ Terminal.text path
        , Terminal.text "\n\n"
        , Terminal.text (errorToString error)
        ]
    }


permanentError : Request value -> Dict String String -> Maybe Error
permanentError request rawResponses =
    case request of
        Request ( urlList, lookupFn ) ->
            case lookupFn rawResponses of
                Ok ( partiallyStrippedResponses, nextRequest ) ->
                    permanentError nextRequest rawResponses

                Err error ->
                    case error of
                        MissingHttpResponse _ ->
                            Nothing

                        DecoderError _ ->
                            Just error

        Done value ->
            Nothing


resolve : Request value -> Dict String String -> Result Error value
resolve request rawResponses =
    case request of
        Request ( urlList, lookupFn ) ->
            case lookupFn rawResponses of
                Ok ( partiallyStrippedResponses, nextRequest ) ->
                    resolve nextRequest rawResponses

                Err error ->
                    Err error

        Done value ->
            Ok value


resolveUrls : Request value -> Dict String String -> ( Bool, List Pages.Internal.Secrets.UrlWithSecrets )
resolveUrls request rawResponses =
    case request of
        Request ( urlList, lookupFn ) ->
            case lookupFn rawResponses of
                Ok ( partiallyStrippedResponses, nextRequest ) ->
                    resolveUrls nextRequest rawResponses
                        |> Tuple.mapSecond ((++) urlList)

                Err error ->
                    ( False
                    , urlList
                    )

        Done value ->
            ( True, [] )
