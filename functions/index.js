const functions = require('firebase-functions');
const admin = require('firebase-admin');
const Razorpay = require('razorpay');

admin.initializeApp();

const rzp = new Razorpay({
  key_id: functions.config().razorpay.key_id,
  key_secret: functions.config().razorpay.key_secret,
});

exports.createRazorpayOrder = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'The function must be called while authenticated.'
    );
  }

  const amount = data.amount;
  const currency = data.currency || 'INR';
  const receipt = data.receipt;

  try {
    const order = await rzp.orders.create({
      amount: amount * 100, // exact amount in smallest unit (paise)
      currency: currency,
      receipt: receipt,
      payment_capture: 1,
    });

    return {
      id: order.id,
      amount: order.amount,
      currency: order.currency,
    };
  } catch (error) {
    throw new functions.https.HttpsError('internal', error.message);
  }
});

exports.onPaymentSuccess = functions.firestore
  .document('payments/{paymentId}')
  .onCreate(async (snap, context) => {
    const paymentData = snap.data();
    const userId = paymentData.userId;
    
    // Process payment success...
    
    // Notify user via FCM
    const userDoc = await admin.firestore().collection('users').doc(userId).get();
    const fcmToken = userDoc.data()?.fcmToken;
    
    if (fcmToken) {
      const payload = {
        notification: {
          title: 'Payment Successful',
          body: 'Your payment was processed successfully.',
        },
      };
      
      await admin.messaging().sendToDevice(fcmToken, payload);
    }
});
