import Debug "mo:base/Debug";
import Time "mo:base/Time";
import MoSpec "mo:mospec/MoSpec";

import Main "main";
import Type "Types";
import Text "mo:base/Text";

let day2Actor = await Main.Homework();

let assertTrue = MoSpec.assertTrue;
let describe = MoSpec.describe;
let context = MoSpec.context;
let before = MoSpec.before;
let it = MoSpec.it;
let skip = MoSpec.skip;
let pending = MoSpec.pending;
let run = MoSpec.run;

let homeworkTest : Type.Homework = {
  title = "Test";
  description = "Test";
  dueDate = Time.now();
  completed = false;
};
let homeworkTest2 : Type.Homework = {
  title = "Test2";
  description = "Test";
  dueDate = Time.now();
  completed = false;
};
let homeworkTest3 : Type.Homework = {
  title = "Test3";
  description = "aaa";
  dueDate = Time.now();
  completed = true;
};

let success = run([
  describe(
    "#addHomework",
    [
      it(
        "should add a Homework to Diary",
        do {
          let id = await day2Actor.addHomework(homeworkTest);
          assertTrue(id == 0);
        },
      ),
    ],
  ),
  describe(
    "#getHomework",
    [
      it(
        "should get a Homework by Id",
        do {
          let response = await day2Actor.getHomework(0);
          switch (response) {
            case (#ok(homework)) {
              assertTrue(homework.title == homeworkTest.title);
            };
            case (#err(message)) {
              Debug.trap("Homework not found");
            };
          };
        },
      ),
      it(
        "should get an error when the homework is not found",
        do {
          let response = await day2Actor.getHomework(1);
          switch (response) {
            case (#err(message)) {
              assertTrue(message == "Homework not found: 1");
            };
            case (_) {
              Debug.trap("Not get an error");
            };
          };
        },
      ),
    ],
  ),
  describe(
    "#updateHomework",
    [
      it(
        "should update an existent Homework",
        do {

          let response = await day2Actor.updateHomework(0, homeworkTest2);
          switch (response) {
            case (#ok) {
              true;
            };
            case (#err(message)) {
              Debug.trap(message);
            };
          };
        },
      ),
      it(
        "should update an existent Homework and check contents",
        do {
          let response = await day2Actor.getHomework(0);
          switch (response) {
            case (#ok(homework)) {
              assertTrue(homework.title == "Test2");
            };
            case (#err(message)) {
              Debug.trap("Homework not found");
            };
          };
        },
      ),
    ],
  ),
  describe(
    "#markAsCompleted",
    [
      it(
        "should mark as complete an existent Homework",
        do {
          let response = await day2Actor.markAsCompleted(0);
          switch (response) {
            case (#ok) {
              true;
            };
            case (#err(message)) {
              Debug.trap("Homework not found");
            };
          };
        },
      ),
      it(
        "should mark as complete an existent Homework and check contents",
        do {
          let response = await day2Actor.getHomework(0);
          switch (response) {
            case (#ok(homework)) {
              assertTrue(homework.completed == true);
            };
            case (#err(message)) {
              Debug.trap("Homework not found");
            };
          };
        },
      ),
    ],
  ),
  describe(
    "#deleteHomework",
    [
      it(
        "should delete an existent Homework",
        do {
          let response = await day2Actor.deleteHomework(0);
          switch (response) {
            case (#ok) {
              true;
            };
            case (#err(message)) {
              Debug.trap(message);
            };
          };
        },
      ),
      it(
        "should delete an existent Homework and check",
        do {
          let response = await day2Actor.getHomework(0);
          switch (response) {
            case (#err(message)) {
              assertTrue(message == "Homework not found: 0");
            };
            case (_) {
              Debug.trap("Not get an error");
            };
          };
        },
      ),
    ],
  ),
  describe(
    "#getAllHomework",
    [
      it(
        "should get all Homeworks",
        do {

          ignore await day2Actor.addHomework(homeworkTest);
          ignore await day2Actor.addHomework(homeworkTest3);
          let response = await day2Actor.getAllHomework();
          assertTrue(response.size() == 2);
        },
      ),
    ],
  ),
  describe(
    "#getPendingHomework",
    [
      it(
        "should get Homework not completed",
        do {
          let response = await day2Actor.getPendingHomework();
          assertTrue(response.size() == 1);
        },
      ),
    ],
  ),
  describe(
    "#searchHomework",
    [
      it(
        "should return first match of term with title",
        do {
          let response = await day2Actor.searchHomework("t3");
          assertTrue(response[0].title == "Test3");
        },
      ),
      it(
        "should return first match of term with description",
        do {
          let response = await day2Actor.searchHomework("aa");
          assertTrue(response[0].title == "Test3");
        },
      ),
    ],
  ),
]);

if (success == false) {
  Debug.trap("Tests failed");
};
