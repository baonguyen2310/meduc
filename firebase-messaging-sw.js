importScripts('https://www.gstatic.com/firebasejs/9.6.1/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/9.6.1/firebase-messaging-compat.js');
importScripts('firebase-init.js');

const messaging = firebase.messaging();

messaging.onBackgroundMessage(function(payload) {});
