import * as admin from "firebase-admin";
admin.initializeApp();

export { sendRiskAlerts } from "./notifications/sendRiskAlerts";
export { recalculateRanking } from "./ranking/recalculateRanking";