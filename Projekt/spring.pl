% === Hilfsprädikate ===

ersetze([_|T], 0, X, [X|T]).
ersetze([H|T], I, X, [H|R]) :-
    I > 0,
    I1 is I - 1,
    ersetze(T, I1, X, R).

% === Neues Spielfeld-Layout ===

% Zeilen des Spielfelds (Index-Positionen)
%
spalten([
    [6,13,20],
    [7,14,21],
    [0,3,8,15,22,27,30],
    [1,4,9,16,23,28,31],
    [2,5,10,17,24,29,32],
    [11,18,25],
    [12,19,26]
]).


zeilen([
    [0, 1, 2],
    [3, 4, 5],
    [6, 7, 8, 9, 10, 11, 12],
    [13, 14, 15, 16, 17, 18, 19],
    [20, 21, 22, 23, 24, 25, 26],
    [27, 28, 29],
    [30, 31, 32]
]).

% Zug entlang vertikaler Linien (Spalten)
zug(Von, Über, Nach) :-
    spalten(Spalten),
    member(Spalte, Spalten),
    (   append(_, [Von, Über, Nach | _], Spalte)
    ;   append(_, [Nach, Über, Von | _], Spalte)
    ).

% Zug entlang horizontaler Linien (Zeilen)
zug(Von, Über, Nach) :-
    zeilen(Zeilen),
    member(Zeile, Zeilen),
    (   append(_, [Von, Über, Nach | _], Zeile)
    ;   append(_, [Nach, Über, Von | _], Zeile)
    ).

% === Startfeld: 33 Felder, nur Mitte leer ===

start_feld(Feld) :-
    length(Feld0, 33),
    maplist(=(x), Feld0),
    ersetze(Feld0, 16, o, Feld).

% === Ziel: nur Mitte (16) belegt ===

ziel(Feld) :-
    length(Feld, 33),
    forall(
        between(0, 32, Index),
        (nth0(Index, Feld, Wert),
         (Index =:= 16 -> Wert == x ; Wert == o))
    ).

% === Züge anwenden ===

wende_zug_an(Feld, zug(Von, Über, Nach), NeuesFeld) :-
    nth0(Von, Feld, x),
    nth0(Über, Feld, x),
    nth0(Nach, Feld, o),
    ersetze(Feld, Von, o, F1),
    ersetze(F1, Über, o, F2),
    ersetze(F2, Nach, x, NeuesFeld).

% === Spielfeld anzeigen ===
zeige_feld(Feld) :-
    zeilen(Zeilen),
    nummerierte_zeilen(Zeilen, 0, Nummerierte),
    nl,
    forall(member(Nr-Zeile, Nummerierte), (
        zeilen_padding(Nr, Padding),
        tab(Padding),
        maplist(index_zu_symbol(Feld), Zeile, Symbole),
        maplist(write, Symbole),
        nl
    )),
    nl.

nummerierte_zeilen([], _, []).
nummerierte_zeilen([Z|Rest], N, [N-Z|NR]) :-
    N1 is N + 1,
    nummerierte_zeilen(Rest, N1, NR).

% Genaues Padding je Zeile (5 Leerzeichen für kurze Zeilen)
zeilen_padding(0, 4).
zeilen_padding(1, 4).
zeilen_padding(2, 0).
zeilen_padding(3, 0).
zeilen_padding(4, 0).
zeilen_padding(5, 4).
zeilen_padding(6, 4).

index_zu_symbol(Feld, Index, Symbol) :-
    nth0(Index, Feld, Inhalt),
    (Inhalt = x -> Symbol = 'x ' ; Symbol = '. ').


% === Löser ===
zeige_zuege(_, []) :-
    write('Fertig!'), nl.

zeige_zuege(Feld, [Zug|Rest]) :-
    write(Zug), nl,
    wende_zug_an(Feld, Zug, NeuesFeld),
    zeige_feld(NeuesFeld),
    zeige_zuege(NeuesFeld, Rest).



feld_mit_x(IndicesMitO, Feld) :-
    length(Feld0, 33),
    maplist(=('x'), Feld0),           % Erst überall x
    setze_os(Feld0, IndicesMitO, Feld).

setze_os(Feld, [], Feld).
setze_os(FeldAlt, [Idx|Rest], FeldNeu) :-
    ersetze(FeldAlt, Idx, o, FeldZwisch),
    setze_os(FeldZwisch, Rest, FeldNeu).
% Basisfall: Keine Züge mehr -> Startfeld = Zielfeld
%wende_zuege_an(+Feld, -Zuege, -Zielfeld, +MaxTiefe)
wende_zuege_an(Feld, [], Feld, _MaxTiefe).  % Keine Züge: Start = Ziel

wende_zuege_an(Feld, [Zug|Rest], Zielfeld, MaxTiefe) :-
    MaxTiefe > 0,
    zug(Von, Über, Nach),
    Zug = zug(Von, Über, Nach),
    wende_zug_an(Feld, Zug, NeuesFeld),
    MaxTiefe1 is MaxTiefe - 1,
    wende_zuege_an(NeuesFeld, Rest, Zielfeld, MaxTiefe1).













