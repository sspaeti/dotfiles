import json5

# import json

# Load the copied settings file
with open("vscode/settings.json", "r") as f:
    data = json5.load(f)

# Remove the unwanted dictionaries
if "codegpt.apiKey" in data:
    del data["codegpt.apiKey"]

# Save the modified data back to the copied file
with open("vscode/settings.json", "w") as f:
    f.write(json5.dumps(data, indent=4))
    # json.dump(data, f, indent=4) #this will print without leading commas
