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
exports.sendRiskAlerts = void 0;
const scheduler_1 = require("firebase-functions/v2/scheduler");
const admin = __importStar(require("firebase-admin"));
const firebase_functions_1 = require("firebase-functions");
const db = admin.firestore();
const WINDOW_SECONDS = 6 * 60 * 60; // 21600
exports.sendRiskAlerts = (0, scheduler_1.onSchedule)({
    schedule: "0 */6 * * *",
    timeZone: "Asia/Bangkok",
    region: "asia-southeast1",
}, async () => {
    const windowKey = Math.floor(Date.now() / 1000 / WINDOW_SECONDS) * WINDOW_SECONDS;
    firebase_functions_1.logger.info(`[sendRiskAlerts] windowKey=${windowKey}`);
    // 1. Query high/critical areas
    const areasSnap = await db
        .collection("areas")
        .where("riskLevel", "in", ["high", "critical"])
        .get();
    if (areasSnap.empty) {
        firebase_functions_1.logger.info("[sendRiskAlerts] no high/critical areas found");
        return;
    }
    // 2. Query eligible users
    const usersSnap = await db
        .collection("users")
        .where("notificationsEnabled", "==", true)
        .get();
    const tokens = usersSnap.docs
        .map((d) => d.data().fcmToken ?? "")
        .filter((t) => t.length > 0);
    if (tokens.length === 0) {
        firebase_functions_1.logger.info("[sendRiskAlerts] no users with valid fcmTokens");
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
                firebase_functions_1.logger.info(`[sendRiskAlerts] already sent for area ${areaId} this window, skipping`);
                continue;
            }
            const area = areaDoc.data();
            const VALID_RISK_LEVELS = ["low", "medium", "high", "critical"];
            const areaRiskLevel = area.riskLevel;
            if (!areaRiskLevel || !VALID_RISK_LEVELS.includes(areaRiskLevel)) {
                firebase_functions_1.logger.warn(`[sendRiskAlerts] area ${areaId} has invalid riskLevel: ${areaRiskLevel}, skipping`);
                continue;
            }
            const title = `⚠️ Dengue Risk Alert: ${area.riskLevel?.toUpperCase()}`;
            const body = `${area.subDistrict ?? ""}, ${area.district ?? ""} — riskScore: ${area.riskScore?.toFixed(1)}`;
            // Send FCM
            const response = await admin.messaging().sendEachForMulticast({
                tokens,
                notification: { title, body },
                data: { areaId, riskLevel: area.riskLevel ?? "" },
            });
            firebase_functions_1.logger.info(`[sendRiskAlerts] area=${areaId} success=${response.successCount} fail=${response.failureCount}`);
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
        }
        catch (err) {
            firebase_functions_1.logger.error(`[sendRiskAlerts] error for area ${areaDoc.id}:`, err);
        }
    }
});
//# sourceMappingURL=sendRiskAlerts.js.map