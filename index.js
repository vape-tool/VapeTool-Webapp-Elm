  const firebaseConfig = {
    apiKey: process.env.API_KEY,
    authDomain: process.env.AUTH_DOMAIN,
    databaseURL: process.env.DATABASE_URL,
    projectId: process.env.PROJECT_ID,
    storageBucket: process.env.STORAGE_BUCKET,
    messagingSenderId: process.env.MESSAGING_SENDER_ID,
    appId: process.env.APP_ID,
  };


  firebase.initializeApp(firebaseConfig);

  const provider = new firebase.auth.GoogleAuthProvider();
  const db = firebase.database();

  import { Elm } from './src/Main.elm'
  const app = Elm.Main.init();

  app.ports.signInWithGoogle.subscribe(() => {
    console.log("LogIn called");
    firebase
      .auth()
      .signInWithPopup(provider,)
      .then(result => {
        result.user.getIdToken().then(idToken => {
          app.ports.signInInfo.send({
            token: idToken,
            email: result.user.email,
            uid: result.user.uid
          });
        });
      })
      .catch(error => {
        app.ports.signInError.send({
          code: error.code,
          message: error.message
        });
      });
  });

  app.ports.signOut.subscribe(() => {
    console.log("LogOut called");
    firebase.auth().signOut();
  });

  //  Observer on user info
  firebase.auth().onAuthStateChanged(user => {
    console.log("called");
    if (user) {
      user
        .getIdToken()
        .then(idToken => {
          app.ports.signInInfo.send({
            token: idToken,
            email: user.email,
            uid: user.uid
          });
        })
        .catch(error => {
          console.log("Error when retrieving cached user");
          console.log(error);
        });

      // Set up listened on new messages
      db.ref(`users/${user.uid}`).on('value', (snapshot) => {
        const data = snapshot.val();
        console.log("Received new snapshot", data);
      });
    }
  });


  app.ports.saveMessage.subscribe(data => {
    console.log(`saving message to database : ${data.content}`);

    db.collection(`users/${data.uid}/messages`)
      .add({
        content: data.content
      })
      .catch(error => {
        app.ports.signInError.send({
          code: error.code,
          message: error.message
        });
      });
  });

