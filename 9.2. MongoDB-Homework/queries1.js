//create database chat
use chat

//create collection messages
db.createCollection('messages');

//create some variables (documents)
var message1 = {};
message1.text = "Zdrasti, haide na po bira";
message1.date = new Date();
message1.isRead = true;
message1.user = {
    username: "Gustera",
    fullname: "Guster Komodski",
    website: "http://guster.com"
    }
    
var message2 = {};
message2.text = "OK, sled 15 min sym na linia";
message2.date = new Date();
message2.isRead = true;
message2.user = {
    username: "Kakavidata",
    fullname: "Kaka Vida",
    website: "http://kakavida.com"
    }
    
//insert documents into collection messages
db.messages.insert(message1);
db.messages.insert(message2); 

//show documents in collection
db.messages.find().pretty();

//update document
db.messages.update(
    {"user.username": {$eq: "Kakavidata"}},
    {$set: {text: "Ste zakysneq malko, chakai me sled 30 min"}},
    {multi: true}
    );
    
db.messages.find().pretty();

//при мен тези не тръгнаха, много се рових из нета, но не можах да намеря нещо което да подкарам в Robomongo
//dump database (backup)
mongodump  --db chat --collection messages;

//restore database
mongorestore --db chat

