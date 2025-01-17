module NextPrevious exposing (..)

import Css
import Html.Styled exposing (..)
import Html.Styled.Attributes as Attr exposing (css)
import Route
import Serialize as S
import Svg.Styled exposing (path, svg)
import Svg.Styled.Attributes as SvgAttr
import Tailwind.Utilities as Tw


type alias Item =
    { title : String, slug : String }


serialize : S.Codec Never { title : String, slug : String }
serialize =
    S.record Item
        |> S.field .title S.string
        |> S.field .slug S.string
        |> S.finishRecord


view : ( Maybe Item, Maybe Item ) -> Html msg
view ( maybeLeft, maybeRight ) =
    div
        [ css
            [ Tw.pt_16
            ]
        ]
        [ nav
            [ css
                [ Tw.flex
                , Tw.flex_row
                , Tw.items_center
                , Tw.justify_between
                ]
            ]
            [ maybeLeft
                |> Maybe.map
                    (\left ->
                        div []
                            [ link (Route.Docs__Section__ { section = Just left.slug })
                                [ linkStyle
                                , Attr.title left.title
                                ]
                                [ leftArrow
                                , text left.title
                                ]
                            ]
                    )
                |> Maybe.withDefault empty
            , maybeRight
                |> Maybe.map
                    (\right ->
                        div []
                            [ link (Route.Docs__Section__ { section = Just right.slug })
                                [ linkStyle
                                , Attr.title right.title
                                ]
                                [ text right.title
                                , rightArrow
                                ]
                            ]
                    )
                |> Maybe.withDefault empty
            ]
        ]


link : Route.Route -> List (Attribute msg) -> List (Html msg) -> Html msg
link route attrs children =
    Route.toLink
        (\anchorAttrs ->
            a
                (List.map Attr.fromUnstyled anchorAttrs ++ attrs)
                children
        )
        route


empty : Html msg
empty =
    div [] []


linkStyle : Attribute msg
linkStyle =
    css
        [ Tw.text_lg
        , Tw.font_medium
        , Tw.p_4
        , Tw.neg_m_4
        , Tw.no_underline |> Css.important
        , Tw.text_gray_600 |> Css.important
        , Tw.flex
        , Tw.items_center
        , Tw.mr_2
        , Css.hover
            [ Tw.text_blue_700 |> Css.important
            ]
        ]


leftArrow : Html msg
leftArrow =
    svg
        [ SvgAttr.height "24"
        , SvgAttr.fill "none"
        , SvgAttr.viewBox "0 0 24 24"
        , SvgAttr.stroke "currentColor"
        , SvgAttr.css
            [ Tw.transform
            , Tw.inline
            , Tw.flex_shrink_0
            , Tw.rotate_180
            , Tw.mr_1
            ]
        ]
        [ path
            [ SvgAttr.strokeLinecap "round"
            , SvgAttr.strokeLinejoin "round"
            , SvgAttr.strokeWidth "2"
            , SvgAttr.d "M9 5l7 7-7 7"
            ]
            []
        ]


rightArrow : Html msg
rightArrow =
    svg
        [ SvgAttr.height "24"
        , SvgAttr.fill "none"
        , SvgAttr.viewBox "0 0 24 24"
        , SvgAttr.stroke "currentColor"
        , SvgAttr.css
            [ Tw.transform
            , Tw.inline
            , Tw.flex_shrink_0
            , Tw.ml_1
            ]
        ]
        [ path
            [ SvgAttr.strokeLinecap "round"
            , SvgAttr.strokeLinejoin "round"
            , SvgAttr.strokeWidth "2"
            , SvgAttr.d "M9 5l7 7-7 7"
            ]
            []
        ]
