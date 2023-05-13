import Buffer "mo:base/Buffer";
import Result "mo:base/Result";
import Nat "mo:base/Nat";
import Text "mo:base/Text";
import Array "mo:base/Array";

import Type "Types";

actor class Homework() {
  type Homework = Type.Homework;

  let homeworkDiary = Buffer.Buffer<Homework>(10);

  // Add a new homework task
  public shared func addHomework(homework : Homework) : async Nat {
    homeworkDiary.add(homework);
    return homeworkDiary.size() - 1;
  };

  // Get a specific homework task by id
  public shared query func getHomework(id : Nat) : async Result.Result<Homework, Text> {
    if (id >= homeworkDiary.size()) {
      return #err("Homework not found: " # Nat.toText(id));
    };
    return #ok(homeworkDiary.get(id));
  };

  // Update a homework task's title, description, and/or due date
  public shared func updateHomework(id : Nat, homework : Homework) : async Result.Result<(), Text> {
    if (id >= homeworkDiary.size()) {
      return #err("Homework not found: " # Nat.toText(id));
    };
    homeworkDiary.put(id, homework);
    return #ok;
  };

  // Mark a homework task as completed
  public shared func markAsCompleted(id : Nat) : async Result.Result<(), Text> {
    if (id >= homeworkDiary.size()) {
      return #err("Homework not found: " # Nat.toText(id));
    };
    let homework = homeworkDiary.get(id);
    let homework2 : Type.Homework = {
      title = homework.title;
      description = homework.description;
      dueDate = homework.dueDate;
      completed = true;
    };
    homeworkDiary.put(id, homework2);
    return #ok;
  };

  // Delete a homework task by id
  public shared func deleteHomework(id : Nat) : async Result.Result<(), Text> {
    if (id >= homeworkDiary.size()) {
      return #err("Homework not found: " # Nat.toText(id));
    };
    ignore homeworkDiary.remove(id);
    return #ok;
  };

  // Get the list of all homework tasks
  public shared query func getAllHomework() : async [Homework] {
    return Buffer.toArray(homeworkDiary);
  };

  func isPendingHomework(homework : Homework) : Bool {
    return homework.completed == false;
  };

  // Get the list of pending (not completed) homework tasks
  public shared query func getPendingHomework() : async [Homework] {
    let array = Buffer.toArray(homeworkDiary);
    return Array.filter(array, isPendingHomework);
  };

  func containsTerm(homework : Homework, term : Text) : Bool {
    return Text.contains(homework.title, #text term) or Text.contains(homework.description, #text term);
  };

  // Search for homework tasks based on a search terms
  public shared query func searchHomework(searchTerm : Text) : async [Homework] {
    let f = func(homework : Homework) : Bool {
      return Text.contains(homework.title, #text searchTerm) or Text.contains(homework.description, #text searchTerm);
    };
    let array = Buffer.toArray(homeworkDiary);
    return Array.filter(array, f);
  };
};
