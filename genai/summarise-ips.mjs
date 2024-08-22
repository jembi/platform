import fs from "fs";
import fetch from "node-fetch";

// Configuration
const config = {
  processIPS: false, // Enable IPS processing
  model: "gemma2", // Default model
};

// Read the IPS file
const ipsData = JSON.parse(fs.readFileSync("ips.json", "utf8"));

// Function to extract text from resources
function extractTextFromResources(data) {
  let extractedText = "";
  if (data.entry && Array.isArray(data.entry)) {
    data.entry.forEach((entry) => {
      if (entry.resource && entry.resource.text && entry.resource.text.div) {
        extractedText += entry.resource.text.div + "\n\n";
        1;
      }
    });
  }
  return extractedText.trim();
}

// Prepare the prompt
let prompt;
if (config.processIPS) {
  const extractedText = extractTextFromResources(ipsData);
  prompt = `Please provide a concise medical summary of the following patient information extracted from an IPS (International Patient Summary) file. Focus on key medical details and highlight important information:

${extractedText}`;
} else {
  prompt = `Please provide a medical summary of the following FHIR IPS (International Patient Summary) file. Summarize the key medical information in a concise and clear manner. Highlight important data to be aware of and provide only brief details of less important data:

${JSON.stringify(ipsData, null, 2)}`;
}

// Function to send request to Ollama API
async function getOllamaSummary(prompt) {
  try {
    const response = await fetch("http://localhost:5001/ai/api/generate", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        model: config.model,
        prompt: prompt,
        stream: false,
      }),
    });

    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }

    const data = await response.json();
    return data.response;
  } catch (error) {
    console.error("Error calling Ollama API:", error.message);
    return null;
  }
}

// Main function
async function main() {
  const summary = await getOllamaSummary(prompt);
  if (summary) {
    console.log("Medical Summary:");
    console.log(summary);
  } else {
    console.log("Failed to generate summary.");
  }
}

main();
