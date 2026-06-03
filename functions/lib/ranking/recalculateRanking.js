"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.recalculateRanking = void 0;
const scheduler_1 = require("firebase-functions/v2/scheduler");
const admin = require("firebase-admin");
const firebase_functions_1 = require("firebase-functions");
const db = admin.firestore();
exports.recalculateRanking = (0, scheduler_1.onSchedule)({
    schedule: "0 */6 * * *",
    timeZone: "Asia/Bangkok",
    region: "asia-southeast1",
}, async () => {
    // Query Bangkok areas — support both English and Thai province name
    const [snapEn, snapTh] = await Promise.all([
        db.collection("areas").where("province", "==", "Bangkok").get(),
        db
            .collection("areas")
            .where("province", "==", "กรุงเทพมหานคร")
            .get(),
    ]);
    const docsMap = new Map();
    for (const doc of [...snapEn.docs, ...snapTh.docs])
        docsMap.set(doc.id, doc);
    const docs = Array.from(docsMap.values());
    if (docs.length === 0) {
        firebase_functions_1.logger.info("[recalculateRanking] no Bangkok areas found");
        return;
    }
    // Sort by riskScore descending
    docs.sort((a, b) => {
        var _a, _b;
        return ((_a = b.data().riskScore) !== null && _a !== void 0 ? _a : 0) -
            ((_b = a.data().riskScore) !== null && _b !== void 0 ? _b : 0);
    });
    // Upsert into ranking/ in batches of 500
    const now = admin.firestore.FieldValue.serverTimestamp();
    const BATCH_SIZE = 500;
    for (let i = 0; i < docs.length; i += BATCH_SIZE) {
        const batch = db.batch();
        const chunk = docs.slice(i, i + BATCH_SIZE);
        chunk.forEach((doc, idx) => {
            var _a, _b, _c, _d;
            const area = doc.data();
            const rank = i + idx + 1;
            const rawScore = typeof area.riskScore === "number" ? area.riskScore : 0;
            const riskScore = rawScore >= 0 && rawScore <= 100 ? rawScore : 0;
            batch.set(db.collection("ranking").doc(doc.id), {
                areaId: doc.id,
                subDistrict: (_a = area.subDistrict) !== null && _a !== void 0 ? _a : "",
                district: (_b = area.district) !== null && _b !== void 0 ? _b : "",
                province: (_c = area.province) !== null && _c !== void 0 ? _c : "",
                riskScore,
                riskLevel: (_d = area.riskLevel) !== null && _d !== void 0 ? _d : "low",
                rank,
                updatedAt: now,
            });
        });
        await batch.commit();
        firebase_functions_1.logger.info(`[recalculateRanking] committed batch ${Math.floor(i / BATCH_SIZE) + 1}`);
    }
    firebase_functions_1.logger.info(`[recalculateRanking] done — ranked ${docs.length} areas`);
});
//# sourceMappingURL=recalculateRanking.js.map