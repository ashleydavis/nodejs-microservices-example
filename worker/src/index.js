'use strict';

const express = require('express');
const mongodb = require('mongodb');

const PORT = process.env.PORT || 80;
const HOST = process.env.HOST || "0.0.0.0";
const DBHOST = process.env.DBHOST || "mongodb://localhost:27017";

function startServer(app) {
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

    const client = await mongodb.MongoClient.connect(DBHOST);
    const db = client.db("mydb");

    const app = express();

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

    await startServer(app);
}

main() 
    .then(() => console.log("Online"))
    .catch(err => {
        console.error("Failed to start!");
        console.error(err && err.stack || err);
    });
