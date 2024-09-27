import { NextResponse } from "next/server";

const useGroq = false; // Set this to false to use the local API
const groqApiKey = "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"; // Replace with your actual Groq API key

export async function POST(request: Request) {
  try {
    const { ipsData } = await request.json();

    const prompt = `You are a medical doctor providing a summary of a patient's medical history to a colleague. Use the following FHIR IPS (International Patient Summary) data to create a concise, narrative summary of the patient's medical history. Only focus on medically relevant data not the data format itself.

    ${JSON.stringify(ipsData)}`;

    let response;
    if (useGroq) {
      response = await fetch(
        "https://api.groq.com/openai/v1/chat/completions",
        {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            Authorization: `Bearer ${groqApiKey}`,
          },
          body: JSON.stringify({
            model: "llama-3.1-70b-versatile",
            messages: [{ role: "user", content: prompt }],
          }),
        }
      );
    } else {
      response = await fetch("http://localhost:5001/ai/api/generate", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: "custom test",
        },
        body: JSON.stringify({
          model: "llama3.2",
          prompt: prompt,
          stream: false,
        }),
      });
    }

    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }

    const data = await response.json();
    let result;
    if (useGroq) {
      // Extracting the content from the full data response
      result = { response: data.choices[0].message.content };
    } else {
      result = data;
    }
    return NextResponse.json(result);
  } catch (error) {
    console.error("Error summarizing with AI:", error);
    return NextResponse.json(
      { error: "Error summarizing with AI" },
      { status: 500 }
    );
  }
}
