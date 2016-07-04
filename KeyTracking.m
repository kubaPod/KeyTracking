(* Mathematica Package *)
(* Created by Mathematica Plugin for IntelliJ IDEA *)

(* :Title: KeyTracking *)
(* :Context: KeyTracking` *)
(* :Author: Kuba Podkalicki *)
(* :Date: 2016-07-04 *)

(* :Package Version: 0.1 *)
(* :Mathematica Version: V10.x.x+ *)
(* :Copyright: (c) 2016 Kuba Podkalicki *)
(* :Keywords: Dynamic, TrackedSymbols, tracking parts*)
(* :Discussion: .md*)

BeginPackage["KeyTracking`"];

  SetKeyTracking; DynamicKey;

Begin["`Private`"];

  SetKeyTracking::usage = "SetKeyTracking[asso] initializes key tracking feature for asso.";
  SetAttributes[SetKeyTracking, HoldFirst];

  SetKeyTracking[asso_] := With[{
    symbolContext = TrackedSymbolContext[asso]},
    Module[{guard},

      asso /: Set[asso[keys__], value_] /; ! TrueQ[guard] :=
          Block[{guard = True}
            ,
            ToExpression[
              symbolContext <> TrackedSymbolName[asso[keys]],
              StandardForm,
              Function[val, val = ! TrueQ @ val, HoldFirst]
            ];

            Set[asso[keys], value]
          ]]];


  SetAttributes[{TrackedSymbolFullName, TrackedSymbolName, TrackedSymbolContext}, HoldFirst];

  TrackedSymbolFullName[asso_[keys__]] := TrackedSymbolContext[asso] <> TrackedSymbolName[asso[keys]];

  TrackedSymbolContext[asso_] := Context[Unevaluated @ asso] <> SymbolName[Unevaluated @ asso] <> "`";

  TrackedSymbolName[asso_[keys__]] := StringJoin @ Most @ Flatten[{"key", ToString[#], "`"} & /@ {keys}];




  DynamicKey::usage = "
    DynamicKey[expr, TrackedSymbols :> {asso[key, ...]}], updates expr when asso[key, ...] changes,
    DynamicKey[asso[key, ...]] automatically takes care of tracking.";

  SetAttributes[DynamicKey, HoldAll];

  DynamicKey[asso_[keys__]] /; Head[asso] === Association :=
      With[{ trSymName = TrackedSymbolFullName[asso[keys]] }, ToExpression[
        trSymName,
        StandardForm,
        Function[
          symbol,
          DynamicKey[asso[keys], symbol],
          HoldFirst
        ] (*why is this so tough to build held expressions?*)
      ]
      ];

  DynamicKey[asso_[keys__], keySymbol_] /; Head[asso] === Association := Dynamic[
    Refresh[keySymbol; asso[keys],TrackedSymbols :> {keySymbol}],
    (asso[keys] = #) &
  ];

  DynamicKey[expr_, TrackedSymbols :> {asso_[keys__]}] :=
      With[{ trSymName = TrackedSymbolFullName[asso[keys]] }, ToExpression[
        trSymName,
        StandardForm,
        Function[
          symbol,
          DynamicKey[expr, asso[keys], symbol],
          HoldFirst
        ] (*why is this so tough to build held expressions?*)
      ]
      ];

  DynamicKey[expr_, asso_[keys__], keySymbol_] /;
      Head[asso] === Association :=
      Dynamic[keySymbol; expr, TrackedSymbols :> {keySymbol}];


End[];
EndPackage[];