"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.updateRiskScores = exports.migrateNotificationDistricts = exports.sendDailyRiskNotifications = void 0;
const admin = require("firebase-admin");
const scheduler_1 = require("firebase-functions/v2/scheduler");
const axios_1 = require("axios");
var sendDailyRiskNotifications_1 = require("./notifications/sendDailyRiskNotifications");
Object.defineProperty(exports, "sendDailyRiskNotifications", { enumerable: true, get: function () { return sendDailyRiskNotifications_1.sendDailyRiskNotifications; } });
var migrateNotificationDistricts_1 = require("./notifications/migrateNotificationDistricts");
Object.defineProperty(exports, "migrateNotificationDistricts", { enumerable: true, get: function () { return migrateNotificationDistricts_1.migrateNotificationDistricts; } });
admin.initializeApp();
const db = admin.firestore();
// ─── WHO risk formula (mirrors Dart RiskScoreCalculator) ─────────
function tempScore(t) {
    if (t < 15 || t > 40)
        return 0;
    if (t >= 25 && t <= 30)
        return 1;
    if (t < 25)
        return (t - 15) / 10;
    return (40 - t) / 10;
}
function humidityScore(h) {
    if (h <= 40)
        return 0;
    return Math.min((h - 40) / 60, 1);
}
function rainfallScore(r) {
    if (r <= 0)
        return 0;
    if (r <= 100)
        return r / 100;
    if (r <= 250)
        return 1 - ((r - 100) / 150) * 0.5;
    return 0.5;
}
function calculateScore(temp, humidity, rain) {
    const raw = 0.4 * tempScore(temp) + 0.3 * humidityScore(humidity) + 0.3 * rainfallScore(rain);
    return Math.max(0, Math.min(1, raw));
}
function levelFromScore(score) {
    if (score < 0.25)
        return "low";
    if (score < 0.50)
        return "medium";
    if (score < 0.75)
        return "high";
    return "critical";
}
// ─── Scheduled Cloud Function — runs once daily at 06:00 Bangkok ─
exports.updateRiskScores = (0, scheduler_1.onSchedule)({
    schedule: "0 6 * * *",
    timeZone: "Asia/Bangkok",
    region: "asia-southeast1",
}, async () => {
    console.log("[RiskUpdate] starting daily update...");
    // Read latest areas (fallback to all if no isLatest docs yet)
    let sourceDocs = (await db.collection("areas").where("isLatest", "==", true).get()).docs;
    if (sourceDocs.length === 0) {
        sourceDocs = (await db.collection("areas").get()).docs;
    }
    const batch = db.batch();
    let updated = 0;
    for (const doc of sourceDocs) {
        const data = doc.data();
        const location = data.location;
        try {
            const { data: weatherData } = await axios_1.default.get("https://api.open-meteo.com/v1/forecast", {
                params: {
                    latitude: location.latitude,
                    longitude: location.longitude,
                    current: "temperature_2m,relative_humidity_2m,rain",
                    timezone: "Asia/Bangkok",
                },
                timeout: 10000,
            });
            const current = weatherData === null || weatherData === void 0 ? void 0 : weatherData.current;
            if (!current)
                continue;
            const temp = current.temperature_2m;
            const humidity = current.relative_humidity_2m;
            const rain = current.rain;
            const score = calculateScore(temp, humidity, rain);
            const level = levelFromScore(score);
            // 1. Set previous isLatest document to false
            const oldDocs = await db
                .collection("areas")
                .where("district", "==", data.district)
                .where("isLatest", "==", true)
                .get();
            oldDocs.forEach((old) => batch.update(old.ref, { isLatest: false }));
            // 2. Create new daily document in areas
            batch.set(db.collection("areas").doc(), {
                district: data.district,
                province: data.province,
                location: location,
                riskScore: score * 100,
                riskLevel: level,
                temperature: temp,
                humidity: humidity,
                rain: rain,
                isLatest: true,
                reportedAt: admin.firestore.Timestamp.now(),
            });
            updated++;
        }
        catch (err) {
            console.error(`[RiskUpdate] failed for ${doc.id}:`, err);
        }
    }
    await batch.commit();
    console.log(`[RiskUpdate] done — ${updated} areas updated`);
});
//# sourceMappingURL=index.js.map