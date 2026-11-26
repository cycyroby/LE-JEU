:- dynamic plateau/1. % permet l'assertion et le retrait de faits plateau/1
largeur_plateau(7).
hauteur_plateau(6).

%récupérer la valeur d'une case dans le tableau 2D
recupereCase(Plateau, L, H, Valeur) :-
  nth0(H*largeur_plateau + L, Plateau, Valeur).

% Pas d'argument, on va chercher le plateau en base. On pourrait le passer en argument.
affichePlateau :-
    plateau(Plateau),
    afficheLignes(Plateau),
    nl.

afficheLignes([]).
afficheLignes([A,B,C,D, E, F, G|Plateau]) :-
    afficheLignes(Plateau),
    afficheCase(A), write(' '),
    afficheCase(B), write(' '),
    afficheCase(C), write(' '),
    afficheCase(D), write(' '),
    afficheCase(E), write(' '),
    afficheCase(F), write(' '),
    afficheCase(G), nl.

afficheCase(C) :- var(C), write('?').
afficheCase(C) :- nonvar(C), write(C).

%%%%% les 8 manières de gagner (on peut faire autrment et lister tous les tableaux gagnants. C'est moins élégant et difficile pour un autre jeu plus complexe)

alignement(0,1,2). alignement(3,4,5). alignement(6,7,8). % lignes
alignement(0,3,6). alignement(1,4,7). alignement(2,5,8). % colonnes
alignement(0,4,8). alignement(2,4,6).                     % diagonales

% +Plateau, -Joueur : on cherche si un joueur gagne
% on teste chaque alignement, on vérifie sur la première position que ce n'est pas une variable, on vérifie ensuite que les 2 autres positions ont la même valeur.
gagne(Plateau, Joueur) :-
    alignement(I1, I2, I3),
    nth0(I1, Plateau, X), nonvar(X),
    nth0(I2, Plateau, Y), X == Y,
    nth0(I3, Plateau, Z), X == Z,
    Joueur = X.

% Égalité
% vrai si plus aucun coup jouable : il n'existe aucune case dans le plateau qui est une variable
% négation par l'echec : on ne peut pas prouver que C est membre du plateau et aussi est une variable.
egalite :- plateau(Plateau), \+ ( member(C, Plateau), var(C) ).

% Changement de joueur
changer(r, j).
changer(j, r).



% +Plateau, -Coup, +Joueur : choisit au hasard parmi les cases libres
% findall très utile pour trouver tous les coups.
dernier(X,[X]).
dernier(X,[_|Tail]) :- dernier(X, Tail).

membre(Elem,[Elem]).
membre(Elem, [Head|Tail]) :- Elem = Head; membre(Elem, Tail).

append([], [], []).
append(L1, [L2h|L2t], [ConcatL1L2h|ConcatL1L2t]) :- L1 = [], L2h = ConcatL1L2h, append(L1, L2t, ConcatL1L2t).
append([L1h|L1t], L2, [ConcatL1L2h|ConcatL1L2t]) :- not([L1h|L1t] = []), L1h = ConcatL1L2h, append(L1t, L2, ConcatL1L2t).

inv([], []).
inv([L1h|L1t], L2) :- dernier(LastElem, L2), LastElem = L1h, append(FirstPart, [LastElem], L2), inv(L1t, FirstPart).

ia(Plateau, Coup, _Joueur) :-
 	inv(Plateau, InvPlateau),
  length(LastLine, 7),
  append(LastLine, _, InvPlateau),
  findall(I, (nth0(I, LastLine, Variable), var(Variable)), Libres),
  random_member(Coup, Libres).
%here, we want to change, Plateau with the seven last places.

% Jouer un coup
% +Plateau, +Coup, -NouveauPlateau, +Joueur
% Construit une nouvelle liste (l'ancien plateau n'est pas modifié).
% https://www.swi-prolog.org/pldoc/man?predicate=nth0/4 est très pratique !
jouerCoup(Plateau, Coup, NouveauPlateau, Joueur) :-
    nth0(Coup, Plateau, Case, Reste),          % on "récupère" la case et le reste
    var(Case),                                 % elle doit être libre, mais si ia est bien codé c'est tjs le cas
    nth0(Coup, NouveauPlateau, Joueur, Reste). % on crée le nouveau platau avec le coup à jouer et le reste
jouerCoup(Plateau, Coup, NouveauPlateau, Joueur) :-
    largeur_plateau(L),
    nth0(Coup, Plateau, Case, Reste),
    nonvar(Case),
    nth0(Coup, NouveauPlateau, Case, Reste),
    NextCoup is Coup+L,
    jouerCoup(Plateau, NextCoup, NouveauPlateau, Joueur).

% Mise à jour de la base de connaissance
% +Plateau, +NouveauPlateau
appliquer(_Plateau, NouveauPlateau) :-
    retract(plateau(_)),
    assert(plateau(NouveauPlateau)).

% Prédicat principal
jouer(Joueur) :-
    plateau(Plateau),
    affichePlateau,
    write('New turn for: '), writeln(Joueur),
    ia(Plateau, Coup, Joueur),
    %read(Coup),
    jouerCoup(Plateau, Coup, NouveauPlateau, Joueur),
    appliquer(Plateau, NouveauPlateau),
    (   gagne(NouveauPlateau, Gagnant)
    ->  affichePlateau, write(Gagnant), writeln(' wins!')
    ;   egalite
    ->  affichePlateau, writeln('Egalité.')
    ;   changer(Joueur, NouveauJoueur),
        jouer(NouveauJoueur)
    ).

% On lance le jeu
go :-
    retractall(plateau(_)), % permet de relancer go plusieurs fois
    largeur_plateau(Largeur),
    hauteur_plateau(Hauteur),
    TaillePlateau is Largeur*Hauteur,
    length(L, TaillePlateau),           % tableau de 42 variables (6*7)
    assert(plateau(L)),
    jouer(r).

%-----------------------------tests----------------------------
testAffichage :-
  retractall(plateau(_)),
  largeur_plateau(Largeur),
  hauteur_plateau(Hauteur),
  TaillePlateau is Largeur*Hauteur,
  length(P, TaillePlateau),
  assert(plateau(P)),
  affichePlateau,
  affichePlateau
  .

testJouer :-
  retractall(plateau(_)),
  largeur_plateau(Largeur),
  hauteur_plateau(Hauteur),
  TaillePlateau is Largeur*Hauteur,
  length(P, TaillePlateau),
  assert(plateau(P)),
  affichePlateau,
  jouerCoup(P, 1, NouveauPlateau, j),
  appliquer(P, NouveauPlateau),
  affichePlateau
  .

testJouer2 :-
  retractall(plateau(_)),
  largeur_plateau(Largeur),
  hauteur_plateau(Hauteur),
  TaillePlateau is Largeur*Hauteur,
  length(P, TaillePlateau),
  assert(plateau(P)),
  affichePlateau,
  writeln('j in 1'),
  jouerCoup(P, 1, NouveauPlateau, j),
  appliquer(P, NouveauPlateau),
  affichePlateau,
  writeln('r in 1'),
  plateau(P1),
  jouerCoup(P1, 1, NouveauPlateau, r),
  appliquer(P1, NouveauPlateau),
  affichePlateau,
  writeln('j in 2'),
  plateau(P2),
  jouerCoup(P2, 2, NouveauPlateau, j),
  appliquer(P2, NouveauPlateau),
  affichePlateau
  .
%read pour si on veut jouer
