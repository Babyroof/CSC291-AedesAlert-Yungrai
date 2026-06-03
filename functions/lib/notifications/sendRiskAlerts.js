"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.sendRiskAlerts = void 0;
const scheduler_1 = require("firebase-functions/v2/scheduler");
const admin = require("firebase-admin");
const firebase_functions_1 = require("firebase-functions");
const db = admin.firestore();
const WINDOW_SECONDS = 6 * 60 * 60; // 21600
exports.sendRiskAlerts = (0, scheduler_1.onSchedule)({
    schedule: "0 */6 * * *",
    timeZone: "Asia/Bangkok",
    region: "asia-southeast1",
}, async () => {
    var _a, _b, _c, _d, _e, _f;
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
        .map((d) => { var _a; return (_a = d.data().fcmToken) !== null && _a !== void 0 ? _a : ""; })
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
            const title = `⚠️ Dengue Risk Alert: ${(_a = area.riskLevel) === null || _a === void 0 ? void 0 : _a.toUpperCase()}`;
            const body = `${(_b = area.subDistrict) !== null && _b !== void 0 ? _b : ""}, ${(_c = area.district) !== null && _c !== void 0 ? _c : ""} — riskScore: ${(_d = area.riskScore) === null || _d === void 0 ? void 0 : _d.toFixed(1)}`;
            // Send FCM
            const response = await admin.messaging().sendEachForMulticast({
                tokens,
                notification: { title, body },
                data: { areaId, riskLevel: (_e = area.riskLevel) !== null && _e !== void 0 ? _e : "" },
            });
            firebase_functions_1.logger.info(`[sendRiskAlerts] area=${areaId} success=${response.successCount} fail=${response.failureCount}`);
            // Write to notifications collection
            await db.collection("notifications").add({
                title,
                body,
                relatedZone: db.collection("areas").doc(areaId),
                sentAt: admin.firestore.FieldValue.serverTimestamp(),
                readBy: [],
                targetDistrict: (_f = area.district) !== null && _f !== void 0 ? _f : "",
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