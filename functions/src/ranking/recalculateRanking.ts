import { onSchedule } from "firebase-functions/v2/scheduler";
import * as admin from "firebase-admin";
import { logger } from "firebase-functions";

const db = admin.firestore();

export const recalculateRanking = onSchedule(
  {
    schedule: "0 */6 * * *",
    timeZone: "Asia/Bangkok",
    region: "asia-southeast1",
  },
  async () => {
    // Query Bangkok areas — support both English and Thai province name
    const [snapEn, snapTh] = await Promise.all([
      db.collection("areas").where("province", "==", "Bangkok").get(),
      db
        .collection("areas")
        .where("province", "==", "กรุงเทพมหานคร")
        .get(),
    ]);

    const docsMap = new Map<
      string,
      admin.firestore.QueryDocumentSnapshot
    >();
    for (const doc of [...snapEn.docs, ...snapTh.docs])
      docsMap.set(doc.id, doc);
    const docs = Array.from(docsMap.values());

    if (docs.length === 0) {
      logger.info("[recalculateRanking] no Bangkok areas found");
      return;
    }

    // Sort by riskScore descending
    docs.sort(
      (a, b) =>
        ((b.data().riskScore as number) ?? 0) -
        ((a.data().riskScore as number) ?? 0)
    );

    // Upsert into ranking/ in batches of 500
    const now = admin.firestore.FieldValue.serverTimestamp();
    const BATCH_SIZE = 500;
    for (let i = 0; i < docs.length; i += BATCH_SIZE) {
      const batch = db.batch();
      const chunk = docs.slice(i, i + BATCH_SIZE);
      chunk.forEach((doc, idx) => {
        const area = doc.data();
        const rank = i + idx + 1;
        const rawScore = typeof area.riskScore === "number" ? area.riskScore : 0;
        const riskScore = rawScore >= 0 && rawScore <= 100 ? rawScore : 0;
        batch.set(db.collection("ranking").doc(doc.id), {
          areaId: doc.id,
          subDistrict: area.subDistrict ?? "",
          district: area.district ?? "",
          province: area.province ?? "",
          riskScore,
          riskLevel: area.riskLevel ?? "low",
          rank,
          updatedAt: now,
        });
      });
      await batch.commit();
      logger.info(
        `[recalculateRanking] committed batch ${Math.floor(i / BATCH_SIZE) + 1}`
      );
    }

    logger.info(`[recalculateRanking] done — ranked ${docs.length} areas`);
  }
);