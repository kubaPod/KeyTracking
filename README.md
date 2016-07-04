# KeyTracking
Mathematica / Wolfram Language package, provides a mini framework to trigger Dynamics by specific key value changes
rather than by association's symbol.

You don't have to create separate symbol for each key and update association manually, KeyTracking` will do that for you!

This framework is not a panacea for performance tuning in Dynamics. But can help with common usage.

### Installation

    (
     CreateDirectory[#];
     URLSave[
        "https://raw.githubusercontent.com/kubaPod/KeyTracking/master/KeyTracking.m", 
        FileNameJoin[{#, "KeyTracking.m"}]
     ]
    ) & @ FileNameJoin[{$UserBaseDirectory, "Applications", "KeyTracking"}]


### Example

It's often the case that storing app/gui data in a single association is convenient (readability/accessibility).
But modularized or not code won't allow neat two way binding without prompting every dynamic where sessionData is present.
 
Change in `sessionData["key"]` will prompt every Dynamic containing `sessionData` to update, very inefficient.

    ClearAll[sessionData];
    
    sessionData = Association@Thread[Range[1000] -> .5];
    
    SetKeyTracking[sessionData]
    
    Pane[Multicolumn[
        DynamicKey @ sessionData[#] & /@ Range[Length@Keys@sessionData], 
        50], {All, 300}, Scrollbars ->True
    ]  (*Try this with Dynamic instead of DynamicKey, I dare you*)
    
    Pane[Multicolumn[
         Grid @ {{Key[#], Slider@DynamicKey@sessionData[#]}} & /@ Range[Length@Keys@sessionData],
         50], {All, 300}, Scrollbars ->True
    ]  (*same here *)

### Limitations

 - `DynamicKey` does  not support full `Dynamic` syntax yet
 - won't work with `DynamicModule's` variables (atm)
 - single key tracking only, but nested too (atm)