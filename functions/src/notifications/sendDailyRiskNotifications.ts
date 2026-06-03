import * as admin from "firebase-admin";
import { onSchedule } from "firebase-functions/v2/scheduler";

export const sendDailyRiskNotifications = onSchedule(
  {
    schedule: "30 6 * * *",
    timeZone: "Asia/Bangkok",
    region: "asia-southeast1",
  },
  async () => {
    const db = admin.firestore();

    // Get today's date range (Bangkok midnight to midnight)
    const now = new Date();
    const todayStart = new Date(now.getFullYear(), now.getMonth(), now.getDate(), 0, 0, 0);
    const todayEnd = new Date(now.getFullYear(), now.getMonth(), now.getDate() + 1, 0, 0, 0);

    // Query notifications created today that haven't been pushed yet
    const notifSnap = await db
      .collection("notifications")
      .where("sentAt", ">=", admin.firestore.Timestamp.fromDate(todayStart))
      .where("sentAt", "<", admin.firestore.Timestamp.fromDate(todayEnd))
      .get();

    const unpushed = notifSnap.docs.filter((doc) => !doc.data().pushedAt);

    if (unpushed.length === 0) return;

    const messaging = admin.messaging();

    for (const notifDoc of unpushed) {
      const notif = notifDoc.data();

      // Resolve district: prefer explicit field, fall back to reading relatedZone
      let targetDistrict: string = notif.targetDistrict ?? "";

      if (!targetDistrict && notif.relatedZone) {
        try {
          const areaSnap = await (notif.relatedZone as admin.firestore.DocumentReference).get();
          if (areaSnap.exists) {
            targetDistrict = (areaSnap.data() as Record<string, unknown>)?.district as string ?? "";
          }
        } catch (err) {
          console.error("Failed to resolve district from relatedZone:", err);
        }
      }

      if (!targetDistrict) {
        await notifDoc.ref.update({ pushedAt: admin.firestore.FieldValue.serverTimestamp() });
        continue;
      }

      // Query users in this district with notifications enabled and valid FCM token
      const usersSnap = await db
        .collection("users")
        .where("notificationsEnabled", "==", true)
        .where("district", "==", targetDistrict)
        .get();

      const tokens: string[] = usersSnap.docs
        .map((d) => (d.data().fcmToken as string) ?? "")
        .filter((t) => t.length > 0);

      if (tokens.length > 0) {
        // Send in batches of 500 (FCM limit)
        const BATCH = 500;
        for (let i = 0; i < tokens.length; i += BATCH) {
          const batch = tokens.slice(i, i + BATCH);
          try {
            await messaging.sendEachForMulticast({
              tokens: batch,
              notification: {
                title: notif.title,
                body: notif.body,
              },
              data: {
                notifId: notifDoc.id,
                targetDistrict,
              },
            });
          } catch (err) {
            console.error(`FCM batch error for district ${targetDistrict}:`, err);
            // Continue — stale tokens must not crash the function
          }
        }
      }

      // Mark as pushed regardless of token count
      await notifDoc.ref.update({ pushedAt: admin.firestore.FieldValue.serverTimestamp() });
    }
  }
);