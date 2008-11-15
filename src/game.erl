-module(game).
-author('sempetmer@gmail.com').

-compile(export_all).

-record(game, {width, height, next_piece, current_piece, ground}).

width(#game{width = Width}) ->
    Width.
height(#game{height = Height}) ->
    Height.

new(Width, Height)
  when Width > 4, Height > 4 ->
    #game{width = Width, height = Height,
          next_piece = piece:translate(piece:new(),
                                       {round(Width/2), 0}),
          current_piece = piece:translate(piece:new(),
                                          {round(Width/2), 0}),
          ground = []}.

blocks(#game{current_piece = undefined, ground = Ground}) ->
    Ground;
blocks(#game{current_piece = Piece, ground = Ground}) ->
    Shape = piece:shape(Piece),
    [{Coord, Shape} || Coord <- piece:blocks(Piece)] ++ Ground.

get_block(Game, Coord) ->
    Blocks = blocks(Game),
    case lists:keysearch(Coord, 1, Blocks) of
        {value, {_, Shape}} ->
            Shape;
        _ ->
            undefined
    end.

move_left(Game = #game{current_piece = Piece}) ->
    NewPiece = piece:translate(Piece, {-1, 0}),
    case lists:any(fun(Coord) -> outside(Coord, Game) or hit(Coord, Game) end,
                   piece:blocks(NewPiece)) of
        false ->
            Game#game{current_piece = NewPiece};
        _ ->
            Game
    end.

move_right(Game = #game{current_piece = Piece}) ->
    NewPiece = piece:translate(Piece, {1, 0}),
    case lists:any(fun(Coord) -> outside(Coord, Game) or hit(Coord, Game) end,
                   piece:blocks(NewPiece)) of
        false ->
            Game#game{current_piece = NewPiece};
        _ ->
            Game
    end.

rotate(Game = #game{current_piece = Piece}) ->
    NewPiece = piece:rotate(Piece, r),
    case lists:any(fun(Coord) -> outside(Coord, Game) or hit(Coord, Game) end,
                   piece:blocks(NewPiece)) of
        false ->
            Game#game{current_piece = NewPiece};
        _ ->
            Game
    end.

tick(Game = #game{current_piece = Piece,
                  next_piece = NextPiece,
                  ground = Ground,
                  width = Width}) ->
    NewPiece = piece:translate(Piece, {0, -1}),
    case lists:any(fun(Coord) -> hit(Coord, Game) end,
                   piece:blocks(NewPiece)) of
        false ->
            Game#game{current_piece = NewPiece};
        _ ->
            NewGround = [{Coord, g} || Coord <- piece:blocks(Piece)] ++ Ground,
            Game#game{current_piece = NextPiece,
                      next_piece = piece:translate(piece:new(),
                                                   {round(Width/2), 0}),
                      ground = NewGround}
    end.

hit(Coord = {_X, Y}, #game{height = Height, ground = Ground}) ->
    lists:keymember(Coord, 1, Ground) or (Height + Y < 0).

outside({X, _Y}, #game{width = Width}) ->
    (X < 0) or (X >= Width + 1).
