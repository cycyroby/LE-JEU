decoupe_liste(0, 0, [], []).
decoupe_liste(I, K,[_|T1], L2) :- I \== 0, decoupe_liste(J, K, T1, L2), I is J + 1.
decoupe_liste(0, K, [H|T1], [H|T2]) :- K \== 0, decoupe_liste(0, L, T1, T2), K is L + 1.
decoupe_liste(0, 0, [H|T], []) :- decoupe_liste(0, 0, T, []).

%gagne_ligne(4, J, _).
%gagne_ligne(_, J, []) :- false.
%gagne_ligne(I, J, [J|T]) :- K is I + 1, gagne_ligne(K, J, T).
%gagne_ligne(I, J, [H|T]) :- J \== H, gagne_ligne(0, J, T). 


gagne_ligne(A, [A, A, A, A, B, C, D]).
gagne_ligne(A, [B, A, A, A, A, C, D]).
gagne_ligne(A, [B, C, A, A, A, A, D]).
gagne_ligne(A, [B, C, D, A, A, A, A]).

