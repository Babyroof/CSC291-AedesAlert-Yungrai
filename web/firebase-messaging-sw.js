importScripts('https://www.gstatic.com/firebasejs/10.12.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.12.0/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: "AIzaSyB5g-LZxVOtmwtCUBpqp7zbEVJYtl2M95I",
  authDomain: "yungrai-aedesalert.firebaseapp.com",
  projectId: "yungrai-aedesalert",
  storageBucket: "yungrai-aedesalert.firebasestorage.app",
  messagingSenderId: "718444697672",
  appId: "1:718444697672:web:63829b28ab03a29428e07d",
  measurementId: "G-YTJWSYB1CL"
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage(function(payload) {
  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
    icon: '/icons/Icon-192.png'
  };
  return self.registration.showNotification(notificationTitle, notificationOptions);
});