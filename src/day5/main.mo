import HashMap "mo:base/HashMap";
import Principal "mo:base/Principal";
import Hash "mo:base/Hash";
import Error "mo:base/Error";
import Result "mo:base/Result";
import Array "mo:base/Array";
import Text "mo:base/Text";
import Nat "mo:base/Nat";
import Int "mo:base/Int";
import Iter "mo:base/Iter";
import Timer "mo:base/Timer";
import Debug "mo:base/Debug";
import Buffer "mo:base/Buffer";

import IC "Ic";
import HTTP "Http";
import Type "Types";

actor class Verifier() {
  type StudentProfile = Type.StudentProfile;
  let MANAGEMENT_CANISTER_ID = "aaaaa-aa";

  let studentProfileStore = HashMap.HashMap<Principal, StudentProfile>(
    10,
    Principal.equal,
    Principal.hash,
  );

  // STEP 1 - BEGIN
  public shared ({ caller }) func addMyProfile(profile : StudentProfile) : async Result.Result<(), Text> {
    studentProfileStore.put(caller, profile);
    return #ok;
  };

  public shared ({ caller }) func seeAProfile(p : Principal) : async Result.Result<StudentProfile, Text> {
    let profile = studentProfileStore.get(p);
    switch (profile) {
      case (null) {
        #err("Student's profile not found: " # Principal.toText(p));
      };
      case (?profile) { #ok(profile) };
    };
  };

  public shared ({ caller }) func updateMyProfile(profile : StudentProfile) : async Result.Result<(), Text> {
    let old = studentProfileStore.replace(caller, profile);
    switch (old) {
      case (null) {
        #err("Student's profile not found: " # Principal.toText(caller));
      };
      case (?old) { #ok };
    };
  };

  public shared ({ caller }) func deleteMyProfile() : async Result.Result<(), Text> {
    let old = studentProfileStore.remove(caller);
    switch (old) {
      case (null) {
        #err("Student's profile not found: " # Principal.toText(caller));
      };
      case (?old) { #ok };
    };
  };
  // STEP 1 - END

  // STEP 2 - BEGIN
  type calculatorInterface = Type.CalculatorInterface;
  public type TestResult = Type.TestResult;
  public type TestError = Type.TestError;

  public func test(canisterId : Principal) : async TestResult {
    let calculator : calculatorInterface = actor (Principal.toText(canisterId));

    try {
      let result = await calculator.reset();
      if (result != 0) {
        return #err(#UnexpectedValue("reset failure"));
      };

      let result2 = await calculator.add(2);
      if (result2 != 2) {
        return #err(#UnexpectedValue("add failure"));
      };

      let result3 = await calculator.sub(1);
      if (result3 != 1) {
        return #err(#UnexpectedValue("sub failure"));
      };

      return #ok;
    } catch (e) {
      return #err(#UnexpectedError(Error.message(e)));
    };
  };
  // STEP - 2 END

  // STEP 3 - BEGIN
  // NOTE: Not possible to develop locally,
  // as actor "aaaaa-aa" (aka the IC itself, exposed as an interface) does not exist locally
  public func verifyOwnership(canisterId : Principal, p : Principal) : async Bool {
    let ic : IC.ManagementCanisterInterface = actor (MANAGEMENT_CANISTER_ID);
    try {
      ignore await ic.canister_status({ canister_id = canisterId });
    } catch (e) {
      let errorMessage = Error.message(e);
      let lines = Iter.toArray(Text.split(errorMessage, #text("\n")));
      let words = Iter.toArray(Text.split(lines[1], #text(" ")));
      var i = 2;
      while (i < words.size()) {
        var p2 = Principal.fromText(words[i]);
        if (p == p2) {
          return true;
        };
        i += 1;
      };
    };
    return false;
  };

  public func canisterStatueErrorMessage(canisterId : Principal, p : Principal) : async Result.Result<(), Text> {
    let ic : IC.ManagementCanisterInterface = actor (MANAGEMENT_CANISTER_ID);
    try {
      ignore await ic.canister_status({ canister_id = canisterId });
      #ok;
    } catch (e) {
      #err(Error.message(e));
    };
  };
  // STEP 3 - END

  // STEP 4 - BEGIN

  func graduate(p : Principal) : Result.Result<(), Text> {
    let profile = studentProfileStore.get(p);
    switch (profile) {
      case (null) {
        #err("Student's profile not found: " # Principal.toText(p));
      };
      case (?profile) {
        let newProfile : StudentProfile = {
          name = profile.name;
          team = profile.team;
          graduate = true;
        };
        studentProfileStore.put(p, newProfile);
        #ok;
      };
    };
  };

  public shared ({ caller }) func verifyWork(canisterId : Principal, p : Principal) : async Result.Result<(), Text> {
    let result = await test(canisterId);
    switch (result) {
      case (#ok) {
        let verified = await verifyOwnership(canisterId, p);
        if (verified) {
          return graduate(p);
        };
        return #err("Not owner: " # Principal.toText(p));
      };
      case (#err(#UnexpectedValue(message))) { return #err(message) };
      case (#err(#UnexpectedError(message))) { return #err(message) };
    };
  };
  // STEP 4 - END

  // STEP 5 - BEGIN
  public type HttpRequest = HTTP.HttpRequest;
  public type HttpResponse = HTTP.HttpResponse;

  // NOTE: Not possible to develop locally,
  // as Timer is not running on a local replica
  public func activateGraduation() : async () {
    return ();
  };

  public func deactivateGraduation() : async () {
    return ();
  };

  public query func http_request(request : HttpRequest) : async HttpResponse {
    return ({
      status_code = 200;
      headers = [];
      body = Text.encodeUtf8("");
      streaming_strategy = null;
    });
  };
  // STEP 5 - END
};
