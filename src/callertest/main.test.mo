import Debug "mo:base/Debug";

import MoSpec "mo:mospec/MoSpec";
import Principal "mo:base/Principal";

import Main "main";
import Stub "stub";

let main = await Main.Main();
let stub = await Stub.Stub();

let assertTrue = MoSpec.assertTrue;
let describe = MoSpec.describe;
let context = MoSpec.context;
let before = MoSpec.before;
let it = MoSpec.it;
let skip = MoSpec.skip;
let pending = MoSpec.pending;
let run = MoSpec.run;

let success = run([
  describe(
    "#getCaller",
    [
      it(
        "should return this principal",
        do {
          let response = await main.getCaller();
          Debug.print(debug_show (response));
          assertTrue(response == Principal.fromText("wo5qg-ysjiq-5da"));
        },
      ),
      it(
        "should return the stub principal",
        do {
          let response = await stub.getCaller();
          Debug.print(debug_show (response));
          assertTrue(response == Principal.fromText("lw2we-tsjiq-5de"));
        },
      ),
    ],
  ),
]);

if (success == false) {
  Debug.trap("Tests failed");
};
