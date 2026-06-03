import * as admin from "firebase-admin";
import { onDocumentWritten } from "firebase-functions/v2/firestore";

export const createNotificationsOnRiskUpdate = onDocumentWritten(
  { document: "areas/{areaId}", region: "asia-southeast1" },
  async (event) => {
    const after = event.data?.after?.data();
    if (!after) return; // document deleted — ignore

    // Only create notification for high or critical risk
    const riskLevel: string = after.riskLevel ?? "";
    if (riskLevel !== "high" && riskLevel !== "critical") return;

    // Only create for latest records
    if (after.isLatest !== true) return;

    const district: string = after.district ?? "";
    const riskScore: number = after.riskScore ?? 0;
    const areaId = event.params.areaId;

    const riskEmoji = riskLevel === "critical" ? "🚨" : "⚠️";
    const riskLabel = riskLevel.charAt(0).toUpperCase() + riskLevel.slice(1);

    const db = admin.firestore();
    await db.collection("notifications").add({
      title: `${riskEmoji} Daily Risk Update — ${district}`,
      body: `Mosquito breeding risk in ${district} has been updated to ${riskLabel} (score: ${riskScore.toFixed(1)})`,
      relatedZone: db.collection("areas").doc(areaId),
      sentAt: admin.firestore.FieldValue.serverTimestamp(),
      readBy: [],
      targetDistrict: district,
    });
  }
);