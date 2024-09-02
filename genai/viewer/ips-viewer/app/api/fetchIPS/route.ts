import { NextResponse } from "next/server";

export async function GET(request: Request) {
  const { searchParams } = new URL(request.url);
  const patientId = searchParams.get("patientId");

  try {
    const response = await fetch(
      `http://localhost:5001/fhir/Patient/${patientId}/$summary?_mdm=true`,
      {
        headers: {
          Authorization: "custom test",
          "Content-Type": "application/fhir+json",
        },
      }
    );

    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }

    const data = await response.json();
    return NextResponse.json(data);
  } catch (error) {
    console.error("Error fetching IPS:", error);
    return NextResponse.json({ error: "Error fetching IPS" }, { status: 500 });
  }
}
