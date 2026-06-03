import * as admin from "firebase-admin";
import { onCall } from "firebase-functions/v2/https";

export const migrateNotificationDistricts = onCall(
  { region: "asia-southeast1" },
  async () => {
    const db = admin.firestore();
    const snap = await db.collection("notifications").get();

    let updated = 0;
    let skipped = 0;
    let failed = 0;

    for (const doc of snap.docs) {
      const data = doc.data();

      // Skip if targetDistrict already set
      if (data.targetDistrict) {
        skipped++;
        continue;
      }

      // Skip if no relatedZone reference
      if (!data.relatedZone) {
        skipped++;
        continue;
      }

      try {
        const areaRef = data.relatedZone as admin.firestore.DocumentReference;
        const areaSnap = await areaRef.get();

        if (!areaSnap.exists) {
          console.warn(`Area not found for notification ${doc.id}`);
          failed++;
          continue;
        }

        const areaData = areaSnap.data() as Record<string, unknown>;
        const district = (areaData?.district as string) ?? "";

        if (!district) {
          console.warn(`Area ${areaRef.id} has no district field`);
          failed++;
          continue;
        }

        await doc.ref.update({ targetDistrict: district });
        updated++;
        console.log(`Updated notification ${doc.id} → district: ${district}`);
      } catch (err) {
        console.error(`Failed to migrate notification ${doc.id}:`, err);
        failed++;
      }
    }

    return { updated, skipped, failed };
  }
);