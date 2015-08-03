//create database blog
use blog

//create collection posts
db.createCollection('posts');

//create some documents
var post1 = {};
post1.title = "Problem with MongoDB backup database";
post1.content = "Cannot creat backup of database; mongodump and mongo export dont work?????";
post1.date = new Date();
post1.category = "MongoDB";
post1.tags = ["NoSQL, MongoDB", "Databases"];
post1.author = {
    username: "programista",
    tweeter: "@velik_programist",
    linkedin: "programistgoliam"
    }
    
var post2 = {};
post2.title = "Solution of the problem with MongoDB backup database";
post2.content = "try to execute commands in the cmd";
post2.date = new Date();
post2.category = "MongoDB";
post2.tags = ["NoSQL, MongoDB", "Databases"];
post2.author = {
    username: "opiten",
    tweeter: "@try_this",
    linkedin: "nistonerazbiram"
    }
    
//insert documents into collection
db.posts.insert(post1); 
db.posts.insert(post2); 

//show documents in collection
db.posts.find().pretty();
