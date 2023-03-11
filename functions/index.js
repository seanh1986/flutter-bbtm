const functions = require("firebase-functions");

const admin = require("firebase-admin");

admin.initializeApp(functions.config().firebase);
let msgData;

// initialized the firebase app
exports.tournamentTrigger = functions.firestore.document(
    "tournaments/{tournamentId}"
).onWrite((snapshot, context) => {
    msgData = snapshot.data();

    admin.firestore().collection("tokens").get().then((snapshots) => {
        const tokens = [];

        if (snapshots.empty) {
            console.log("No Devices Found");
        } else {
            for (const pushTokens of snapshots.docs) {
                tokens.push(pushTokens.data().token);
            }

            const payload = {
                // 'notification': {
                //     'title': 'From ' + msgData.businessType,
                //     'body': 'Offer is : ' + msgData.offer,
                //     'sound': 'default',
                // },
                "data": {
                    "tournamentId": msgData.tournamentId,
                },
            };

            return admin.messaging().sendToDevice(tokens, payload)
                .then((response) => {
                    console.log("pushed them all");
                }).catch((err) => {
                    console.log(err);
                });
        }
    });
});

// // Create and deploy your first functions
// // https://firebase.google.com/docs/functions/get-started
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
