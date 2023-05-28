import Principal "mo:base/Principal";
import Main "main";

actor class Stub() {
  public func getCaller() : async Principal {
    let main = await Main.Main();

    return await main.getCaller();
  };
};
