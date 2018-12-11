FROM mongo

COPY fixture.json /fixture.json
CMD mongoimport --host db --db mydb --collection mycollection --type json --file /fixture.json --jsonArray