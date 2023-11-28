(*To test GUI, run [make gui] in terminal*)

open Bogue
module W = Widget
module L = Layout

let main () =
  (* create label widgets for heading *)
  let title_label = W.label "OCAML STOCKS" in
  let date_label = W.label "November 21, 2023" in
  let watch_lst_label = W.label "Watch List" in
  let portfolio_lst_label = W.label "My Portfolio" in

  (* create main containers *)
  let heading_container =
    L.flat_of_w ~name:"heading_container" [ title_label; date_label ]
  in
  let second_tier_container =
    L.flat_of_w ~name:"second_tier_container"
      [ watch_lst_label; portfolio_lst_label ]
  in

  let main_container =
    L.tower ~name:"main_container" [ heading_container; second_tier_container ]
  in

  let board = Bogue.of_layout main_container in
  Bogue.run board

let () =
  main ();
  Bogue.quit ()
