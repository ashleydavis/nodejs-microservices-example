'use strict';

const express = require('express');
const axios = require('axios');

const PORT = process.env.PORT || 80;
const HOST = process.env.HOST || "0.0.0.0";
const SERVICE_URL = process.env.SERVICE_URL || "http://worker"; 

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

    const app = express();

    app.get("/", (req, res) => {
        res.send('Hello computer!\n');
    });

    app.get("/api/data", async (req, res) => {
        const response = await axios.get(SERVICE_URL + "/api/data")
        res.json(response.data);
    });

    await startServer(app);
}

main() 
    .then(() => console.log("Online"))
    .catch(err => {
        console.error("Failed to start!");
        console.error(err && err.stack || err);
    });
