import {onDocumentCreated} from "firebase-functions/v2/firestore";
import {initializeApp} from "firebase-admin/app";

initializeApp();

export const onNewPostCreated = onDocumentCreated(
  {document: "posts/{postId}"},

  async (event) => {
    if (!event.data) {
      console.log("No data associated with the event.");
      return;
    }

    const postSnapshot = event.data;
    const postId = postSnapshot.id;
    const postData = postSnapshot.data();

    console.log("--- New Post Detected (Server-Side) ---");
    console.log(`Post ID: ${postId}`);
    console.log(`Message: "${postData.message}"`);
    console.log(`Posted by: ${postData.username}`);
    console.log(`Timestamp (DB): ${postData.timestamp.toDate().toISOString()}`);
    console.log("-----------------------------------------");

    return;
  }
);
