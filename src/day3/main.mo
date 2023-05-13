import Type "Types";
import Buffer "mo:base/Buffer";
import Result "mo:base/Result";
import Array "mo:base/Array";
import Iter "mo:base/Iter";
import HashMap "mo:base/HashMap";
import Nat "mo:base/Nat";
import Nat32 "mo:base/Nat32";
import Text "mo:base/Text";
import Principal "mo:base/Principal";
import Debug "mo:base/Debug";
import Order "mo:base/Order";
import Hash "mo:base/Hash";

actor class StudentWall() {
  public type Content = Type.Content;

  public type Message = Type.Message;

  func hash(n : Nat) : Nat32 {
    Text.hash(Nat.toText(n));
  };

  var messageId : Nat = 0;
  let wall = HashMap.HashMap<Nat, Message>(10, Nat.equal, hash);
  let logs = Buffer.Buffer<Text>(10);

  // Add a new message to the wall
  public shared ({ caller }) func writeMessage(c : Content) : async Nat {
    let m : Message = {
      vote = 0;
      content = c;
      creator = caller;
    };
    let id = messageId;
    wall.put(id, m);
    messageId += 1;
    return id;
  };

  // Get a specific message by ID
  public shared query func getMessage(messageId : Nat) : async Result.Result<Message, Text> {
    let m = wall.get(messageId);
    switch (m) {
      case (null) {
        return #err("Message not found: " # Nat.toText(messageId));
      };
      case (?message) {
        return #ok(message);
      };
    };
  };

  // Update the content for a specific message by ID
  public shared ({ caller }) func updateMessage(messageId : Nat, c : Content) : async Result.Result<(), Text> {

    let m = wall.get(messageId);
    switch (m) {
      case (null) {
        return #err("Message not found: " # Nat.toText(messageId));
      };
      case (?mes) {
        let m2 : Message = {
          vote = mes.vote;
          content = c;
          creator = mes.creator;
        };
        ignore wall.replace(messageId, m2);
        return #ok;
      };
    };
  };

  // Delete a specific message by ID
  public shared ({ caller }) func deleteMessage(messageId : Nat) : async Result.Result<(), Text> {
    let m = wall.remove(messageId);
    switch (m) {
      case (null) {
        return #err("Message not found: " # Nat.toText(messageId));
      };
      case (?mes) {
        return #ok;
      };
    };
  };

  // Voting
  public func upVote(messageId : Nat) : async Result.Result<(), Text> {
    let m = wall.get(messageId);
    switch (m) {
      case (null) {
        return #err("Message not found: " # Nat.toText(messageId));
      };
      case (?mes) {
        let m2 : Message = {
          vote = mes.vote + 1;
          content = mes.content;
          creator = mes.creator;
        };
        ignore wall.replace(messageId, m2);
        return #ok;
      };
    };
  };

  public func downVote(messageId : Nat) : async Result.Result<(), Text> {
    let m = wall.get(messageId);
    switch (m) {
      case (null) {
        return #err("Message not found: " # Nat.toText(messageId));
      };
      case (?mes) {
        let m2 : Message = {
          vote = mes.vote - 1;
          content = mes.content;
          creator = mes.creator;
        };
        ignore wall.replace(messageId, m2);
        return #ok;
      };
    };
  };

  // Get all messages
  public query func getAllMessages() : async [Message] {
    return Iter.toArray(wall.vals());
  };

  func compare(m1 : Message, m2 : Message) : Order.Order {
    if (m1.vote == m2.vote) { #equal } else if (m1.vote < m2.vote) { #greater } else {
      #less;
    };
  };

  // Get all messages ordered by votes
  public query func getAllMessagesRanked() : async [Message] {
    let array = Iter.toArray(wall.vals());
    return Array.sort(
      array,
      compare,
    );
  };
};
