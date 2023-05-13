import TrieMap "mo:base/TrieMap";
import Trie "mo:base/Trie";
import Result "mo:base/Result";
import Text "mo:base/Text";
import Nat "mo:base/Nat";
import Option "mo:base/Option";
import Debug "mo:base/Debug";

import Account "Account";
// NOTE: only use for local dev,
// when deploying to IC, import from "rww3b-zqaaa-aaaam-abioa-cai"
import BootcampLocalActor "BootcampLocalActor";

actor class MotoCoin() {
  public type Account = Account.Account;

  let ledger = TrieMap.TrieMap<Account, Nat>(Account.accountsEqual, Account.accountsHash);
  var airdropped = false;

  // Returns the name of the token
  public query func name() : async Text {
    return "MotoCoin";
  };

  // Returns the symbol of the token
  public query func symbol() : async Text {
    return "MOC";
  };

  // Returns the the total number of tokens on all accounts
  public func totalSupply() : async Nat {
    var total : Nat = 0;
    for (balance in ledger.vals()) {
      total += balance;
    };
    return total;
  };

  // Returns the balance of the account
  public query func balanceOf(account : Account) : async (Nat) {
    let balance = ledger.get(account);
    return Option.get(balance, 0);
  };

  // Transfer tokens to another account
  public shared ({ caller }) func transfer(
    from : Account,
    to : Account,
    amount : Nat,
  ) : async Result.Result<(), Text> {
    let fromBalance = Option.get(ledger.get(from), 0);
    let toBalance = Option.get(ledger.get(to), 0);

    if (fromBalance < amount) {
      return #err("The balance should be greater or equal to " # Nat.toText(amount) # ", but " # Nat.toText(fromBalance));
    };
    ignore ledger.replace(from, fromBalance - amount);
    ignore ledger.replace(to, toBalance + amount);
    return #ok;
  };

  // Airdrop 100 MotoCoin to any student that is part of the Bootcamp.
  public func airdrop() : async Result.Result<(), Text> {
    if (airdropped) {
      return #ok;
    };

    let bootcampTestActor : actor {
      getAllStudentsPrincipal : shared () -> async [Principal];
    } = actor ("rww3b-zqaaa-aaaam-abioa-cai");
    //let bootcampTestActor = await BootcampLocalActor.BootcampLocalActor();
    let students = await bootcampTestActor.getAllStudentsPrincipal();
    for (p in students.vals()) {
      var account : Account = { owner = p; subaccount = null };
      var balance = Option.get(ledger.get(account), 0);
      ledger.put(account, balance + 100);
    };
    airdropped := true;
    return #ok;
  };
};
