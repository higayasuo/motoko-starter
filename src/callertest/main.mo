import Principal "mo:base/Principal";

actor class Main() {
  public shared ({ caller }) func getCaller() : async Principal {
    return caller;
  };
};
