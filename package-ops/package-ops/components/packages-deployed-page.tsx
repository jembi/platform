"use client";

import { useState, useEffect } from "react";
import Link from "next/link";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { ChevronDownIcon, ChevronUpIcon, SettingsIcon } from "./Icons";
import { Input } from "@/components/ui/input";
import {
  Breadcrumb,
  BreadcrumbList,
  BreadcrumbItem,
  BreadcrumbLink,
  BreadcrumbSeparator,
  BreadcrumbPage,
} from "@/components/ui/breadcrumb";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog";

interface Service {
  name: string;
  replicas: number;
}

interface Stack {
  name: string;
  services: Service[];
}

export function PackagesDeployedPage() {
  const [stacks, setStacks] = useState<Stack[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    fetchStacks();

    // Set up automatic refresh every 5 seconds
    const refreshInterval = setInterval(fetchStacks, 5000);

    // Clean up the interval on component unmount
    return () => clearInterval(refreshInterval);
  }, []);

  const fetchStacks = async () => {
    try {
      const response = await fetch("/api/deployed-stacks");
      if (!response.ok) {
        throw new Error("Failed to fetch deployed stacks");
      }
      const data = await response.json();
      setStacks(data);
      setIsLoading(false);
    } catch (error) {
      console.error("Error fetching deployed stacks:", error);
      setError("Failed to load deployed stacks. Please try again later.");
      setIsLoading(false);
    }
  };

  return (
    <div className="flex min-h-screen w-full">
      <div className="flex flex-col w-full max-w-[1600px] mx-auto px-4 sm:px-6 lg:px-8">
        <header className="sticky top-0 z-30 flex h-14 items-center gap-4 border-b bg-background sm:static sm:h-auto sm:border-0 sm:bg-transparent py-4">
          <Breadcrumb className="hidden md:flex">
            <BreadcrumbList>
              <BreadcrumbItem>
                <BreadcrumbLink asChild>
                  <Link href="#" prefetch={false}>
                    Home
                  </Link>
                </BreadcrumbLink>
              </BreadcrumbItem>
              <BreadcrumbSeparator />
              <BreadcrumbItem>
                <BreadcrumbPage>Deployed Packages</BreadcrumbPage>
              </BreadcrumbItem>
            </BreadcrumbList>
          </Breadcrumb>
          <div className="relative ml-auto flex-1 md:grow-0">
            <SearchIcon className="absolute left-2.5 top-2.5 h-4 w-4 text-muted-foreground" />
            <Input
              type="search"
              placeholder="Search packages..."
              className="w-full rounded-lg bg-background pl-8 md:w-[200px] lg:w-[336px]"
            />
          </div>
        </header>
        <main className="grid grid-cols-1 gap-6 py-6 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4">
          {isLoading ? (
            <p>Loading deployed packages...</p>
          ) : error ? (
            <p className="text-red-500">{error}</p>
          ) : stacks.length === 0 ? (
            <div className="col-span-full text-center py-12">
              <p className="text-xl font-semibold text-gray-600">
                No package stacks are currently running.
              </p>
              <p className="mt-2 text-gray-500">
                Deploy a package to see it listed here.
              </p>
            </div>
          ) : (
            stacks.map((stack) => (
              <PackageCard key={stack.name} stack={stack} />
            ))
          )}
        </main>
      </div>
    </div>
  );
}

function PackageCard({ stack }: { stack: Stack }) {
  const [isExpanded, setIsExpanded] = useState(false);
  const [isConfigOpen, setIsConfigOpen] = useState(false);

  return (
    <Card className="flex flex-col hover:shadow-lg transition-shadow duration-300 relative">
      <CardHeader className="pb-2">
        <CardTitle className="text-xl font-bold">{stack.name}</CardTitle>
        <CardDescription className="text-sm text-muted-foreground">
          {stack.services.length} service
          {stack.services.length !== 1 ? "s" : ""}
        </CardDescription>
        <Dialog open={isConfigOpen} onOpenChange={setIsConfigOpen}>
          <DialogTrigger asChild>
            <Button
              variant="ghost"
              size="icon"
              className="absolute top-2 right-2 h-8 w-8"
            >
              <SettingsIcon className="h-4 w-4" />
            </Button>
          </DialogTrigger>
          <DialogContent className="z-50 bg-white">
            <DialogHeader>
              <DialogTitle>Configure {stack.name}</DialogTitle>
            </DialogHeader>
            {/* Add configuration form content here */}
            <div className="mt-4">
              <p>Configuration options for {stack.name} will go here.</p>
            </div>
          </DialogContent>
        </Dialog>
      </CardHeader>
      <CardContent className="flex flex-col flex-grow p-4">
        <Button
          variant="outline"
          size="sm"
          onClick={() => setIsExpanded(!isExpanded)}
          className="flex items-center w-full justify-between mb-2"
        >
          <span>Services</span>
          {isExpanded ? (
            <ChevronUpIcon className="h-4 w-4" />
          ) : (
            <ChevronDownIcon className="h-4 w-4" />
          )}
        </Button>
        {isExpanded && (
          <ul className="mt-2 space-y-2">
            {stack.services.map((service) => (
              <li
                key={service.name}
                className="flex justify-between items-center text-sm"
              >
                <span>{service.name}</span>
                <span className="px-2 py-1 text-xs font-semibold rounded-full bg-gray-100 text-gray-800">
                  {service.replicas} replica
                  {service.replicas !== 1 ? "s" : ""}
                </span>
              </li>
            ))}
          </ul>
        )}
      </CardContent>
    </Card>
  );
}

function SearchIcon(props: React.SVGProps<SVGSVGElement>) {
  return (
    <svg
      {...props}
      xmlns="http://www.w3.org/2000/svg"
      width="24"
      height="24"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="2"
      strokeLinecap="round"
      strokeLinejoin="round"
    >
      <circle cx="11" cy="11" r="8" />
      <path d="m21 21-4.3-4.3" />
    </svg>
  );
}
