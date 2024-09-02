"use client";

import { useState } from "react";
import ReactMarkdown from "react-markdown";

export default function Home() {
  const [ipsData, setIpsData] = useState(null);
  const [aiSummary, setAiSummary] = useState("");
  const [isLoadingAI, setIsLoadingAI] = useState(false);
  const [isLoadingIPS, setIsLoadingIPS] = useState(false);
  const [patientId, setPatientId] = useState(
    "92a544a2-39ce-4a67-a271-69b2a49774e6"
  );
  const [error, setError] = useState("");

  const fetchIPS = async () => {
    setError("");
    setIsLoadingIPS(true);
    try {
      const response = await fetch(`/api/fetchIPS?patientId=${patientId}`);
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }
      const data = await response.json();
      setIpsData(data);
    } catch (error) {
      console.error("Error fetching IPS:", error);
      setIpsData(null);
      setError(
        `Error fetching IPS: ${
          error instanceof Error ? error.message : String(error)
        }`
      );
    } finally {
      setIsLoadingIPS(false);
    }
  };

  const summarizeWithAI = async () => {
    setIsLoadingAI(true);
    setError("");
    try {
      if (!ipsData) {
        throw new Error("No IPS data available. Please fetch IPS first.");
      }

      const ipsDataCopy = JSON.parse(JSON.stringify(ipsData));

      if (ipsDataCopy.entry && Array.isArray(ipsDataCopy.entry)) {
        ipsDataCopy.entry.forEach((entry) => {
          if (entry.resource && entry.resource.text) {
            delete entry.resource.text;
          }
        });
      }

      const response = await fetch("/api/summarizeAI", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({ ipsData: ipsDataCopy }),
      });

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      const data = await response.json();
      setAiSummary(data.response);
    } catch (error) {
      console.error("Error summarizing with AI:", error);
      setError(
        `Error summarizing with AI: ${
          error instanceof Error ? error.message : String(error)
        }`
      );
    } finally {
      setIsLoadingAI(false);
    }
  };

  const extractNarrativeFromIPS = (ipsData) => {
    if (!ipsData || !ipsData.entry) return "";

    let narrativeHtml = "";
    ipsData.entry.forEach((entry) => {
      if (entry.resource && entry.resource.text && entry.resource.text.div) {
        narrativeHtml += entry.resource.text.div;
      }
    });

    return narrativeHtml;
  };

  return (
    <main className="flex flex-col items-center justify-between p-4 sm:p-8 md:p-16 lg:p-24">
      <div className="z-10 w-full max-w-5xl items-center justify-between font-mono text-sm">
        <div className="fixed left-0 top-0 w-full bg-purple-600 shadow-md z-50">
          <div className="container mx-auto px-4 py-3 flex flex-col sm:flex-row justify-between items-center">
            <h1 className="text-xl font-bold text-white mb-2 sm:mb-0">
              FHIR IPS Illuminator
            </h1>
            <nav>
              <ul className="flex space-x-4">
                <li>
                  <a
                    href="#"
                    className="text-white hover:text-purple-200 transition-colors duration-200"
                  >
                    Home
                  </a>
                </li>
                <li>
                  <a
                    href="#"
                    className="text-white hover:text-purple-200 transition-colors duration-200"
                  >
                    About
                  </a>
                </li>
                <li>
                  <a
                    href="#"
                    className="text-white hover:text-purple-200 transition-colors duration-200"
                  >
                    Contact
                  </a>
                </li>
              </ul>
            </nav>
          </div>
        </div>
      </div>

      <div className="flex flex-col items-center mt-20 w-full max-w-5xl">
        <div className="mb-4 flex flex-col items-center w-full max-w-md">
          <label htmlFor="patientId" className="mb-2 font-bold text-lg">
            Patient ID
          </label>
          <input
            id="patientId"
            type="text"
            value={patientId}
            onChange={(e) => setPatientId(e.target.value)}
            className="mb-4 px-4 py-2 border border-gray-300 rounded w-full text-gray-900 bg-white"
            placeholder="Enter Patient ID"
          />
          <div className="flex flex-col sm:flex-row w-full">
            <button
              onClick={fetchIPS}
              disabled={isLoadingIPS}
              className="mb-2 sm:mb-0 sm:mr-2 px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600 flex-1 disabled:opacity-50"
            >
              {isLoadingIPS ? "Fetching..." : "Fetch IPS Document"}
            </button>
            <button
              onClick={summarizeWithAI}
              disabled={isLoadingAI}
              className="px-4 py-2 bg-gradient-to-r from-purple-500 to-pink-500 text-white rounded hover:from-purple-600 hover:to-pink-600 flex-1 disabled:opacity-50"
            >
              {isLoadingAI ? "Summarizing..." : "Summarise with AI"}
            </button>
          </div>
        </div>

        {error && (
          <div className="mb-4 p-4 bg-red-100 border border-red-400 text-red-700 rounded w-full max-w-md">
            {error}
          </div>
        )}

        {(isLoadingIPS || isLoadingAI) && (
          <div className="mb-4 p-4 bg-gradient-to-r from-blue-500 to-purple-500 text-white rounded flex items-center animate-pulse w-full max-w-md">
            <svg
              className="animate-spin -ml-1 mr-3 h-5 w-5 text-white"
              xmlns="http://www.w3.org/2000/svg"
              fill="none"
              viewBox="0 0 24 24"
            >
              <circle
                className="opacity-25"
                cx="12"
                cy="12"
                r="10"
                stroke="currentColor"
                strokeWidth="4"
              ></circle>
              <path
                className="opacity-75"
                fill="currentColor"
                d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
              ></path>
            </svg>
            <span className="font-semibold">
              {isLoadingIPS
                ? "Fetching IPS data..."
                : "Summarizing IPS data with AI..."}
            </span>
          </div>
        )}

        {aiSummary && (
          <div className="w-full mb-4">
            <h2 className="text-2xl font-bold mb-4">AI Summary</h2>
            <div className="ai-summary-border p-[2px] rounded">
              <div className="bg-gray-800 text-white p-4 rounded">
                <ReactMarkdown
                  className="prose prose-invert max-w-none ai-summary-content"
                  components={{
                    p: ({ node, ...props }) => (
                      <p className="mb-4" {...props} />
                    ),
                    ul: ({ node, ...props }) => (
                      <ul className="list-disc pl-5 mb-4" {...props} />
                    ),
                    ol: ({ node, ...props }) => (
                      <ol className="list-decimal pl-5 mb-4" {...props} />
                    ),
                    li: ({ node, ...props }) => (
                      <li className="mb-2" {...props} />
                    ),
                    h1: ({ node, ...props }) => (
                      <h1 className="text-2xl font-bold mb-4 mt-6" {...props} />
                    ),
                    h2: ({ node, ...props }) => (
                      <h2 className="text-xl font-bold mb-3 mt-5" {...props} />
                    ),
                    h3: ({ node, ...props }) => (
                      <h3 className="text-lg font-bold mb-2 mt-4" {...props} />
                    ),
                  }}
                >
                  {aiSummary}
                </ReactMarkdown>
              </div>
            </div>
          </div>
        )}

        {ipsData && (
          <div className="w-full">
            <h2 className="text-2xl font-bold mb-4">IPS Document Narrative</h2>
            <div
              className="bg-gray-800 text-white p-4 rounded prose prose-invert max-w-none narrative-content overflow-x-auto"
              dangerouslySetInnerHTML={{
                __html: extractNarrativeFromIPS(ipsData),
              }}
            />
          </div>
        )}
      </div>

      <style jsx global>{`
        .narrative-content h1,
        .narrative-content h2,
        .narrative-content h3,
        .narrative-content h4,
        .narrative-content h5,
        .narrative-content h6 {
          font-weight: bold;
          margin-top: 1.5rem;
          margin-bottom: 1rem;
          color: #f7fafc; /* A lighter shade for better contrast */
          border-bottom: 2px solid #4a5568;
          padding-bottom: 0.5rem;
        }
        .narrative-content h1 {
          font-size: 2rem;
        }
        .narrative-content h2 {
          font-size: 1.75rem;
        }
        .narrative-content h3 {
          font-size: 1.5rem;
        }
        .narrative-content h4 {
          font-size: 1.25rem;
        }
        .narrative-content h5 {
          font-size: 1.1rem;
        }
        .narrative-content h6 {
          font-size: 1rem;
        }
        .narrative-content table {
          border-collapse: collapse;
          width: 100%;
          margin-bottom: 1rem;
        }
        .narrative-content th,
        .narrative-content td {
          border: 1px solid #4a5568;
          padding: 0.5rem;
          text-align: left;
        }
        .narrative-content th {
          background-color: #2d3748;
          font-weight: bold;
        }
        .narrative-content tr:nth-child(even) {
          background-color: #2d3748;
        }
        .narrative-content tr:hover {
          background-color: #4a5568;
        }

        @media (max-width: 640px) {
          .narrative-content table {
            font-size: 0.8rem;
          }
          .narrative-content h1 {
            font-size: 1.5rem;
          }
          .narrative-content h2 {
            font-size: 1.3rem;
          }
          .narrative-content h3 {
            font-size: 1.1rem;
          }
          .narrative-content h4,
          .narrative-content h5,
          .narrative-content h6 {
            font-size: 1rem;
          }
        }
      `}</style>

      <style jsx global>{`
        .ai-summary-border {
          background: linear-gradient(to right, #8b5cf6, #ec4899);
        }
      `}</style>
    </main>
  );
}
