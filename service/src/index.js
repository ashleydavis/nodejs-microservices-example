'use strict';

const express = require('express');
const mongodb = require('mongodb');

// Constants
const PORT = process.env.PORT || 80;
const HOST = process.env.HOST || "0.0.0.0";
const DBHOST = process.env.DBHOST || "mongodb://localhost:27017";

// App
const app = express();

function startServer() {
    return new Promise((resolve, reject) => {
        app.listen(PORT, HOST, err => {
            if (err) {
                reject(err);
            }
            else {
                console.log(`Running on http://${HOST}:${PORT}`);
                resolve();
            }
        });
    });
}

async function main() {

    console.log("Starting!");

    const client = await mongodb.MongoClient.connect(DBHOST);
    const db = client.db("mydb");

    app.get("/api/data", (req, res) => {
        const collection = db.collection("mycollection");
        collection.find().toArray()
            .then(data => {
                res.json(data);
            })
            .catch(err => {
                console.error("Error retreiving data.");
                console.error(err && err.stack || err);

                res.sendStatus(500);
            });
    });

    await startServer();
}

main() 
    .then(() => console.log("Online"))
    .catch(err => {
        console.error("Failed to start!");
        console.error(err && err.stack || err);
    });
