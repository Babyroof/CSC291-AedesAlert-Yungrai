"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.recalculateRanking = void 0;
const scheduler_1 = require("firebase-functions/v2/scheduler");
const admin = __importStar(require("firebase-admin"));
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
    docs.sort((a, b) => (b.data().riskScore ?? 0) -
        (a.data().riskScore ?? 0));
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
        firebase_functions_1.logger.info(`[recalculateRanking] committed batch ${Math.floor(i / BATCH_SIZE) + 1}`);
    }
    firebase_functions_1.logger.info(`[recalculateRanking] done — ranked ${docs.length} areas`);
});
//# sourceMappingURL=recalculateRanking.js.map