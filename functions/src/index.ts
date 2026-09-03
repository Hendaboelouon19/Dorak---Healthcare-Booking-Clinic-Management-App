import {initializeApp} from "firebase-admin/app";
import {
  FieldValue,
  getFirestore,
} from "firebase-admin/firestore";
import * as logger from "firebase-functions/logger";
import {
  onDocumentCreated,
  onDocumentUpdated,
} from "firebase-functions/v2/firestore";

initializeApp();

const db = getFirestore();

interface AppointmentData {
  patientId?: string;
  patientName?: string;
  clinicName?: string;
  doctorName?: string;
  status?: string;
  queueNumber?: number;
}

interface CreateNotificationParams {
  patientId: string;
  appointmentId: string;
  notificationId: string;
  title: string;
  message: string;
  type: string;
}

/**
 * Creates a notification only once.
 *
 * A deterministic notification document ID is used so that
 * Cloud Function retries do not create duplicate notifications.
 *
 * @param {CreateNotificationParams} params Notification data.
 */
async function createNotificationOnce(
  params: CreateNotificationParams,
): Promise<void> {
  const {
    patientId,
    appointmentId,
    notificationId,
    title,
    message,
    type,
  } = params;

  const notificationRef = db
    .collection("users")
    .doc(patientId)
    .collection("notifications")
    .doc(notificationId);

  await db.runTransaction(async (transaction) => {
    const existingNotification =
      await transaction.get(notificationRef);

    if (existingNotification.exists) {
      logger.info(
        "Notification already exists. Skipping.",
        {
          appointmentId,
          notificationId,
        },
      );

      return;
    }

    transaction.set(
      notificationRef,
      {
        title,
        message,
        type,
        appointmentId,
        isRead: false,
        createdAt: FieldValue.serverTimestamp(),
      },
    );
  });
}

// ============================================================================
// APPOINTMENT CREATED
//
// New appointment
//      ↓
// "Booking confirmed" notification
// ============================================================================

export const onAppointmentCreated = onDocumentCreated(
  "appointments/{appointmentId}",
  async (event) => {
    const snapshot = event.data;

    if (!snapshot) {
      return;
    }

    const appointment =
      snapshot.data() as AppointmentData;

    const patientId = appointment.patientId;
    const appointmentId = event.params.appointmentId;

    if (!patientId) {
      logger.warn(
        "Appointment created without patientId.",
        {
          appointmentId,
        },
      );

      return;
    }

    const doctorName =
      appointment.doctorName ?? "your doctor";

    const clinicName =
      appointment.clinicName ?? "the clinic";

    await createNotificationOnce({
      patientId,
      appointmentId,
      notificationId:
        `${appointmentId}_bookingConfirmed`,
      title: "Booking confirmed",
      message:
        `Your appointment with ${doctorName} ` +
        `at ${clinicName} has been booked successfully.`,
      type: "bookingConfirmed",
    });

    logger.info(
      "Booking-confirmed notification created.",
      {
        appointmentId,
        patientId,
      },
    );
  },
);

// ============================================================================
// APPOINTMENT UPDATED
//
// Handles:
//
// booked -> inQueue
//      ↓
// Arrival approved
//
// queueNumber -> 1
//      ↓
// You're next
//
// inQueue -> inProgress
//      ↓
// It's your turn
// ============================================================================

export const onAppointmentUpdated = onDocumentUpdated(
  "appointments/{appointmentId}",
  async (event) => {
    const beforeSnapshot = event.data?.before;
    const afterSnapshot = event.data?.after;

    if (!beforeSnapshot || !afterSnapshot) {
      return;
    }

    const before =
      beforeSnapshot.data() as AppointmentData;

    const after =
      afterSnapshot.data() as AppointmentData;

    const appointmentId =
      event.params.appointmentId;

    const patientId =
      after.patientId;

    if (!patientId) {
      logger.warn(
        "Appointment updated without patientId.",
        {
          appointmentId,
        },
      );

      return;
    }

    const notifications: Promise<void>[] = [];

    // ========================================================================
    // 1. ARRIVAL APPROVED
    //
    // Example:
    // booked -> inQueue
    // ========================================================================

    const enteredQueue =
      before.status !== "inQueue" &&
      after.status === "inQueue";

    if (enteredQueue) {
      const queueNumber =
        after.queueNumber ?? 0;

      let message = "Your arrival was approved. " +
  "You are now in the live queue.";

      if (queueNumber > 0) {
        message = `You are now #${queueNumber} in the live queue.`;
      }

      notifications.push(
        createNotificationOnce({
          patientId,
          appointmentId,
          notificationId:
            `${appointmentId}_arrivalApproved`,
          title: "Arrival approved",
          message,
          type: "arrivalApproved",
        }),
      );
    }

    // ========================================================================
    // 2. YOU'RE NEXT
    //
    // The patient is already in the queue and their position
    // changes to queue number 1.
    //
    // Example:
    // 2 -> 1
    // ========================================================================

    const becameNext =
      before.status === "inQueue" &&
      after.status === "inQueue" &&
      before.queueNumber !== 1 &&
      after.queueNumber === 1;

    if (becameNext) {
      notifications.push(
        createNotificationOnce({
          patientId,
          appointmentId,
          notificationId:
            `${appointmentId}_turnApproaching`,
          title: "You're next!",
          message:
            "You're now first in the queue. " +
            "Please stay nearby and be ready.",
          type: "turnApproaching",
        }),
      );
    }

    // ========================================================================
    // 3. IT'S YOUR TURN
    //
    // Example:
    // inQueue -> inProgress
    // ========================================================================

    const doctorReady =
      before.status !== "inProgress" &&
      after.status === "inProgress";

    if (doctorReady) {
      const doctorName =
        after.doctorName ?? "The doctor";

      notifications.push(
        createNotificationOnce({
          patientId,
          appointmentId,
          notificationId:
            `${appointmentId}_doctorReady`,
          title: "It's your turn!",
          message:
            `${doctorName} is ready for you now.`,
          type: "doctorArrived",
        }),
      );
    }

    // Nothing important changed.
    if (notifications.length === 0) {
      return;
    }

    await Promise.all(notifications);

    logger.info(
      "Appointment notifications created.",
      {
        appointmentId,
        patientId,
        count: notifications.length,
      },
    );
  },
);
