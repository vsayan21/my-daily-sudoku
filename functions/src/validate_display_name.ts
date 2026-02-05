import {HttpsError, onCall} from "firebase-functions/v2/https";
import {defineSecret} from "firebase-functions/params";
import * as logger from "firebase-functions/logger";
import * as admin from "firebase-admin";

if (admin.apps.length === 0) {
  admin.initializeApp();
}

const openaiApiKey = defineSecret("OPENAI_API_KEY");

export const validateDisplayName = onCall(
  {secrets: [openaiApiKey]},
  async (request) => {
    const displayName = String(request.data?.displayName ?? "").trim();
    const uid = request.auth?.uid;
    if (!displayName) {
      throw new HttpsError("invalid-argument", "Display name is required.");
    }
    if (displayName.length > 16) {
      return {allowed: false, reason: "too_long"};
    }
    if (!/^[A-Za-z0-9 _-]+$/.test(displayName)) {
      return {allowed: false, reason: "invalid_chars"};
    }
    const lowered = displayName.toLowerCase();
    if (uid) {
      try {
        const usernameSnap = await admin
          .firestore()
          .collection("usernames")
          .doc(lowered)
          .get();
        if (usernameSnap.exists) {
          const existingUid = usernameSnap.data()?.uid as string | undefined;
          if (existingUid && existingUid !== uid) {
            return {allowed: false, reason: "taken"};
          }
        }
      } catch (error) {
        logger.warn("Username check failed", {error});
      }
    }
    const bannedPatterns: RegExp[] = [
      /f\W*u\W*c\W*k/i,
      /sh\W*i\W*t/i,
      /penis/i,
      /cunt/i,
      /dick/i,
      /pussy/i,
      /whore/i,
      /slut/i,
      /idiot/i,
      /arschloch/i,
      /asshole/i,
      /bastard/i,
      /wanker/i,
      /bitch/i,
      /moron/i,
      /retard/i,
      /douche/i,
      /fag/i,
      /puta/i,
      /putain/i,
      /merde/i,
      /merda/i,
      /scheiße|scheisse/i,
      /fotze/i,
      /schlampe/i,
      /verdammt/i,
      /idiota/i,
      /imbecile|imbecil/i,
      /salope/i,
      /connard/i,
      /enculé|encule/i,
      /culo/i,
    ];
    if (bannedPatterns.some((pattern) => pattern.test(lowered))) {
      return {allowed: false, reason: "blocked"};
    }

    const uidKey = uid ?? "anonymous";
    const cacheKey = `name_check:${uidKey}:${displayName.toLowerCase()}`;
    const cacheRef = admin.firestore().doc(`moderationCache/${cacheKey}`);

    try {
      const cached = await cacheRef.get();
      if (cached.exists) {
        const data = cached.data();
        if (data?.allowed === true || data?.allowed === false) {
          return {allowed: data.allowed, reason: data.reason ?? null};
        }
      }
    } catch (error) {
      logger.warn("Moderation cache read failed", {error});
    }

    if (uid) {
      const cooldownRef = admin.firestore().doc(`moderationCooldown/${uid}`);
      try {
        const cooldownSnap = await cooldownRef.get();
        const lastMs = cooldownSnap.data()?.lastMs as number | undefined;
        if (lastMs && Date.now() - lastMs < 10_000) {
          return {allowed: false, reason: "rate_limited"};
        }
        await cooldownRef.set({lastMs: Date.now()}, {merge: true});
      } catch (error) {
        logger.warn("Moderation cooldown check failed", {error});
      }
    }

    const attemptModeration = async () => {
      const response = await fetch("https://api.openai.com/v1/moderations", {
        method: "POST",
        headers: {
          "Authorization": `Bearer ${openaiApiKey.value()}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          model: "omni-moderation-latest",
          input: displayName,
        }),
      });
      const body = await response.text();
      if (!response.ok) {
        logger.error("Moderation request failed", {
          status: response.status,
          body,
        });
        return {ok: false, status: response.status};
      }
      const json = JSON.parse(body);
      const flagged = Boolean(json?.results?.[0]?.flagged);
      return {ok: true, flagged};
    };

    for (let attempt = 0; attempt < 3; attempt += 1) {
      const result = await attemptModeration();
      if (result.ok) {
        const allowed = !result.flagged;
        const payload = {
          allowed,
          reason: allowed ? null : "flagged",
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        };
        try {
          await cacheRef.set(payload, {merge: true});
        } catch (error) {
          logger.warn("Moderation cache write failed", {error});
        }
        return {allowed};
      }
      if (result.status !== 429) {
        return {allowed: false, reason: "service_unavailable"};
      }
      const delayMs = attempt === 0 ? 300 : attempt === 1 ? 800 : 1500;
      await new Promise((resolve) => setTimeout(resolve, delayMs));
    }

    return {allowed: false, reason: "service_unavailable"};
  },
);
