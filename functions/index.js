const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();


// for handel message notification
exports.onNewChatMessage = functions.firestore
  .document("chats/{cid}/messages/{mid}")
  .onCreate(async (snap) => {
    const msg = snap.data();
    if (!msg) return null;

    const toId = msg.toId;
    const fromId = msg.fromId;

    const msgType = (msg.type || "text").toString();
    const senderName = (msg.senderName || "Message").toString();


    const preview =
      msgType === "image" ? "📸 Photo" : (msg.msg || "New message").toString();

    // receiver token
    const userDoc = await admin.firestore().collection("users").doc(toId).get();
    if (!userDoc.exists) return null;

    const token = userDoc.data().pushToken;
    if (!token) return null;

    await admin.messaging().send({
      token,
      data: {
        type: "chat",
        messageType: msgType,      
        otherUserId: String(fromId),
        senderId: String(fromId),
        senderName: String(senderName),
        message: String(preview),  
      },
      android: { priority: "high" },
    });

    return null;
  });




//   for handel call notification
  exports.onIncomingCall = functions.firestore
  .document("calls/{docId}")
  .onCreate(async (snap, context) => {
    const call = snap.data();  
    if (!call) return null;

    const callDocId = context.params.docId;

    const callerId = String(call.callerId || "");
    const callerName = String(call.callerName || "Incoming call");
    const callerPhone = String(call.callerPhone || "");
    const callType = String(call.callType || "audio");

    const participants = Array.isArray(call.participants) ? call.participants : [];
    
    const receivers = participants.filter((id) => String(id) !== callerId);

    if (!callerId || receivers.length === 0) return null;

    // send to each receiver
    for (const receiverId of receivers) {
      const userDoc = await admin.firestore().collection("users").doc(String(receiverId)).get();
      if (!userDoc.exists) continue;

      const token = userDoc.data().pushToken;
      if (!token) continue;

      await admin.messaging().send({
        token,
        data: {
          type: "call",
          callDocId: String(callDocId),
          callId: String(call.callId || callDocId),
          callType: callType,
          callerId: callerId,
          callerName: callerName,
          callerPhone: callerPhone,
        },
        android: { priority: "high" },
      }); 
    }

    return null;
  });