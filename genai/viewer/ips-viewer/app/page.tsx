"use client";

import { useState } from "react";

export default function Home() {
  const [ipsData, setIpsData] = useState(null);
  const [aiSummary, setAiSummary] = useState("");
  const [isLoading, setIsLoading] = useState(false);

  const fetchIPS = async () => {
    try {
      const response = await fetch("/api/fhir/$summary");
      const data = await response.json();
      setIpsData(data);
    } catch (error) {
      console.error("Error fetching IPS:", error);
    }
  };

  const summarizeWithAI = async () => {
    setIsLoading(true);
    try {
      const response = await fetch("/ai/summarise-ips");
      const data = await response.text();
      setAiSummary(data);
    } catch (error) {
      console.error("Error summarizing with AI:", error);
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <main className="flex flex-col items-center justify-between p-24">
      <div className="z-10 w-full max-w-5xl items-center justify-between font-mono text-sm lg:flex">
        <div className="fixed left-0 top-0 w-full bg-white dark:bg-gray-800 shadow-md z-50">
          <div className="container mx-auto px-4 py-3 flex justify-between items-center">
            <h1 className="text-xl font-bold text-gray-800 dark:text-white">
              FHIR IPS Viewer
            </h1>
            <nav>
              <ul className="flex space-x-4">
                <li>
                  <a
                    href="#"
                    className="text-gray-600 hover:text-gray-800 dark:text-gray-300 dark:hover:text-white"
                  >
                    Home
                  </a>
                </li>
                <li>
                  <a
                    href="#"
                    className="text-gray-600 hover:text-gray-800 dark:text-gray-300 dark:hover:text-white"
                  >
                    About
                  </a>
                </li>
                <li>
                  <a
                    href="#"
                    className="text-gray-600 hover:text-gray-800 dark:text-gray-300 dark:hover:text-white"
                  >
                    Contact
                  </a>
                </li>
              </ul>
            </nav>
          </div>
        </div>
      </div>

      <div className="flex flex-col items-center mt-4">
        <div className="mb-4">
          <button
            onClick={fetchIPS}
            className="mr-4 px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600"
          >
            Fetch IPS Document
          </button>

          <button
            onClick={summarizeWithAI}
            className="px-4 py-2 bg-gradient-to-r from-purple-500 to-pink-500 text-white rounded hover:from-purple-600 hover:to-pink-600"
          >
            Summarise with AI
          </button>
        </div>

        {isLoading && (
          <div className="mb-4 text-lg font-semibold">
            Summarizing...
            <span className="animate-pulse">...</span>
          </div>
        )}

        {aiSummary && (
          <div className="mb-4 p-4 bg-gray-100 rounded">
            <h2 className="text-xl font-bold mb-2">AI Summary</h2>
            <p>{aiSummary}</p>
          </div>
        )}

        {ipsData && (
          <div className="w-full">
            <h2 className="text-2xl font-bold mb-4">IPS Document</h2>
            <pre className="bg-gray-100 p-4 rounded overflow-auto">
              {JSON.stringify(ipsData, null, 2)}
            </pre>
          </div>
        )}
      </div>
    </main>
  );
}
