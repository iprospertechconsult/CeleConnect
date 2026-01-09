/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const {setGlobalOptions} = require("firebase-functions");
const {onRequest} = require("firebase-functions/https");
const logger = require("firebase-functions/logger");

// For cost control, you can set the maximum number of containers that can be
// running at the same time. This helps mitigate the impact of unexpected
// traffic spikes by instead downgrading performance. This limit is a
// per-function limit. You can override the limit for each function using the
// `maxInstances` option in the function's options, e.g.
// `onRequest({ maxInstances: 5 }, (req, res) => { ... })`.
// NOTE: setGlobalOptions does not apply to functions using the v1 API. V1
// functions should each use functions.runWith({ maxInstances: 10 }) instead.
// In the v1 API, each function can only serve one request per container, so
// this will be the maximum concurrent request count.
setGlobalOptions({ maxInstances: 10 });

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();
const db = admin.firestore();

exports.swipeRight = functions.https.onCall(async (data, context) => {
  // 1️⃣ Must be authenticated
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "User must be authenticated"
    );
  }

  const me = context.auth.uid;
  const other = data.otherUid;

  if (!other || typeof other !== "string") {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "otherUid is required"
    );
  }

  if (me === other) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Cannot swipe on yourself"
    );
  }

  const now = admin.firestore.Timestamp.now();

  const myLikeRef = db
    .collection("users")
    .doc(me)
    .collection("likesSent")
    .doc(other);

  const theirLikeRef = db
    .collection("users")
    .doc(other)
    .collection("likesSent")
    .doc(me);

  // 2️⃣ Record my like
  await myLikeRef.set({ createdAt: now });

  // 3️⃣ Check reciprocal like
  const theirLikeSnap = await theirLikeRef.get();
  if (!theirLikeSnap.exists) {
    return {
      matched: false
    };
  }

  // 4️⃣ Create match (deterministic ID)
  const a = me < other ? me : other;
  const b = me < other ? other : me;
  const matchId = `${a}_${b}`;

  const matchRef = db.collection("matches").doc(matchId);
  const matchSnap = await matchRef.get();

  if (!matchSnap.exists) {
    await matchRef.set({
      users: [a, b],
      createdAt: now,
      lastMessageAt: now,
      lastMessageText: ""
    });
  }

  return {
    matched: true,
    matchId
  };
});
