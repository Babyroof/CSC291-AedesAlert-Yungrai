import { onSchedule } from "firebase-functions/v2/scheduler";
import * as admin from "firebase-admin";
import { logger } from "firebase-functions";

const db = admin.firestore();
const WINDOW_SECONDS = 6 * 60 * 60; // 21600

export const sendRiskAlerts = onSchedule(
  {
    schedule: "0 */6 * * *",
    timeZone: "Asia/Bangkok",
    region: "asia-southeast1",
  },
  async () => {
    const windowKey =
      Math.floor(Date.now() / 1000 / WINDOW_SECONDS) * WINDOW_SECONDS;
    logger.info(`[sendRiskAlerts] windowKey=${windowKey}`);

    // 1. Query high/critical areas
    const areasSnap = await db
      .collection("areas")
      .where("riskLevel", "in", ["high", "critical"])
      .get();

    if (areasSnap.empty) {
      logger.info("[sendRiskAlerts] no high/critical areas found");
      return;
    }

    // 2. Query eligible users
    const usersSnap = await db
      .collection("users")
      .where("notificationsEnabled", "==", true)
      .get();

    const tokens: string[] = usersSnap.docs
      .map((d) => (d.data().fcmToken as string) ?? "")
      .filter((t) => t.length > 0);

    if (tokens.length === 0) {
      logger.info("[sendRiskAlerts] no users with valid fcmTokens");
      return;
    }

    // 3. Per area: check de-dup, send FCM, write logs
    for (const areaDoc of areasSnap.docs) {
      try {
        const areaId = areaDoc.id;
        // De-dup doc ID is deterministic by design: {areaId}_{6h-window-epoch}.
        // Write access to notificationLogs is denied to all clients via Firestore rules (Admin SDK only).
        const logDocId = `${areaId}_${windowKey}`;
        const logRef = db.collection("notificationLogs").doc(logDocId);
        const logSnap = await logRef.get();
        if (logSnap.exists) {
          logger.info(
            `[sendRiskAlerts] already sent for area ${areaId} this window, skipping`
          );
          continue;
        }

        const area = areaDoc.data();
        const VALID_RISK_LEVELS = ["low", "medium", "high", "critical"];
        const areaRiskLevel = area.riskLevel as string | undefined;
        if (!areaRiskLevel || !VALID_RISK_LEVELS.includes(areaRiskLevel)) {
          logger.warn(`[sendRiskAlerts] area ${areaId} has invalid riskLevel: ${areaRiskLevel}, skipping`);
          continue;
        }
        const title = `⚠️ Dengue Risk Alert: ${area.riskLevel?.toUpperCase()}`;
        const body = `${area.subDistrict ?? ""}, ${area.district ?? ""} — riskScore: ${(area.riskScore as number)?.toFixed(1)}`;

        // Send FCM
        const response = await admin.messaging().sendEachForMulticast({
          tokens,
          notification: { title, body },
          data: { areaId, riskLevel: area.riskLevel ?? "" },
        });
        logger.info(
          `[sendRiskAlerts] area=${areaId} success=${response.successCount} fail=${response.failureCount}`
        );

        // Write to notifications collection
        await db.collection("notifications").add({
          title,
          body,
          relatedZone: db.collection("areas").doc(areaId),
          sentAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        // Write de-dup log
        await logRef.set({
          areaId,
          windowStart: admin.firestore.Timestamp.fromMillis(windowKey * 1000),
          sentAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      } catch (err) {
        logger.error(`[sendRiskAlerts] error for area ${areaDoc.id}:`, err);
      }
    }
  }
);