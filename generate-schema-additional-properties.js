const fs = require('fs');
const path = require('path');

const filePath = process.argv[2];

if (!filePath) {
    console.error('Please provide a file path as a command-line argument.');
    process.exit(1);
}

const resolvedPath = path.resolve(filePath);

function readAdditionalPropertiesFile(filePath) {
    fs.readFile(filePath, 'utf8', (err, data) => {
        if (err) {
            console.error('Error reading file:', err);
            return;
        }
        const additionalProperties = JSON.parse(data);
        AddPropsToSchema(additionalProperties)
    });
};

const AddPropsToSchema = (additionalProperties) => {
    fs.readFile('./schema.json', 'utf8', (err, data) => {
        if (err) {
            console.error('Error reading ./schema.json file:', err);
            return;
        }

        const updatedJson = {
            "$schema": "https://json-schema.org/draft/2020-12/schema",
            "type": "object",
            "additionalProperties": { 
                "type": "object",
                "additionalProperties": additionalProperties
            }            
        }

        fs.writeFile('./schema.json', JSON.stringify(updatedJson, null, 2), 'utf8', (err) => {
            if (err) {
                console.error('Error writing ./schema.json file:', err);
                return;
            }
            console.log('File successfully updated');
        });

    });
};

readAdditionalPropertiesFile(resolvedPath);