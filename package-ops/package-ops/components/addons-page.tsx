"use client";

import Link from "next/link";
import {
  Breadcrumb,
  BreadcrumbList,
  BreadcrumbItem,
  BreadcrumbLink,
  BreadcrumbSeparator,
  BreadcrumbPage,
} from "@/components/ui/breadcrumb";
import { Input } from "@/components/ui/input";
import { Card, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { useState } from "react";
import { PlusIcon, SettingsIcon } from "./Icons";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog";

export function AddonsPage() {
  const [addStatus, setAddStatus] = useState<{ [key: string]: string }>({});

  const handleAdd = async (addonId: string) => {
    setAddStatus((prevStatus) => ({
      ...prevStatus,
      [addonId]: "Adding...",
    }));

    try {
      const response = await fetch("/api/add-addon", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({ addonId }),
      });

      const data = await response.json();

      if (data.success) {
        setAddStatus((prevStatus) => ({
          ...prevStatus,
          [addonId]: "Added",
        }));
      } else {
        throw new Error(data.message || "Failed to add add-on");
      }
    } catch (error) {
      console.error("Error adding add-on:", error);
      setAddStatus((prevStatus) => ({
        ...prevStatus,
        [addonId]: "Failed",
      }));
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
                <BreadcrumbPage>Add-ons</BreadcrumbPage>
              </BreadcrumbItem>
            </BreadcrumbList>
          </Breadcrumb>
          <div className="relative ml-auto flex-1 md:grow-0">
            <SearchIcon className="absolute left-2.5 top-2.5 h-4 w-4 text-muted-foreground" />
            <Input
              type="search"
              placeholder="Search add-ons..."
              className="w-full rounded-lg bg-background pl-8 md:w-[200px] lg:w-[336px]"
            />
          </div>
        </header>
        <main className="grid grid-cols-1 gap-6 py-6 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4">
          <AddonCard
            title="Master Patient Index"
            description="Deploy a system for managing unique patient identifiers across healthcare systems."
            addonId="mpi"
            addStatus={addStatus}
            onAdd={handleAdd}
          />
          <AddonCard
            title="Reporting Pipeline"
            description="Set up a comprehensive data reporting and analytics pipeline."
            addonId="reporting"
            addStatus={addStatus}
            onAdd={handleAdd}
          />
          <AddonCard
            title="Smart Health Links"
            description="Implement intelligent health information linking and sharing capabilities."
            addonId="smart-health-links"
            addStatus={addStatus}
            onAdd={handleAdd}
          />
          <AddonCard
            title="Monitoring Services"
            description="Deploy a suite of monitoring tools for system health and performance tracking."
            addonId="monitoring"
            addStatus={addStatus}
            onAdd={handleAdd}
          />
          <AddonCard
            title="LLM API"
            description="Integrate a Large Language Model API for advanced natural language processing capabilities."
            addonId="llm-api"
            addStatus={addStatus}
            onAdd={handleAdd}
          />
        </main>
      </div>
    </div>
  );
}

interface AddonCardProps {
  title: string;
  description: string;
  addonId: string;
  addStatus: { [key: string]: string };
  onAdd: (addonId: string) => void;
}

function AddonCard({
  title,
  description,
  addonId,
  addStatus,
  onAdd,
}: AddonCardProps) {
  const [isConfigOpen, setIsConfigOpen] = useState(false);
  const [config, setConfig] = useState<{ [key: string]: string }>({});

  const handleConfigChange = (key: string, value: string) => {
    setConfig((prevConfig) => ({
      ...prevConfig,
      [key]: value,
    }));
  };

  return (
    <Card className="flex flex-col relative">
      <CardContent className="flex flex-col flex-grow p-6">
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
          <DialogContent className="bg-background border shadow-lg">
            <DialogHeader>
              <DialogTitle>Configure {title}</DialogTitle>
            </DialogHeader>
            <ConfigurationForm
              addonId={addonId}
              config={config}
              onChange={handleConfigChange}
            />
          </DialogContent>
        </Dialog>
        <div className="flex-grow">
          <h3 className="text-lg font-semibold">{title}</h3>
          <p className="text-muted-foreground mt-2">{description}</p>
          <p className="text-sm text-muted-foreground mt-1">
            Add-on ID: {addonId}
          </p>
        </div>
        <div className="flex mt-4">
          <Button
            size="sm"
            onClick={() => onAdd(addonId)}
            disabled={addStatus[addonId] === "Adding..."}
            className="ml-auto"
          >
            {addStatus[addonId] || (
              <>
                <PlusIcon className="mr-2 h-4 w-4" /> Add
              </>
            )}
          </Button>
        </div>
      </CardContent>
    </Card>
  );
}

interface ConfigurationFormProps {
  addonId: string;
  config: { [key: string]: string };
  onChange: (key: string, value: string) => void;
}

function ConfigurationForm({
  addonId,
  config,
  onChange,
}: ConfigurationFormProps) {
  return (
    <div className="space-y-4">
      <h4 className="font-medium">Configuration</h4>
      <div className="space-y-2">
        <div className="flex items-center space-x-2">
          <label className="text-sm font-medium">{`${addonId.toUpperCase()}_VAR1`}</label>
          <Input
            placeholder={`${addonId.toUpperCase()}_VAR1`}
            value={config.VAR1 || ""}
            onChange={(e) => onChange("VAR1", e.target.value)}
          />
        </div>
        <div className="flex items-center space-x-2">
          <label className="text-sm font-medium">{`${addonId.toUpperCase()}_VAR2`}</label>
          <Input
            placeholder={`${addonId.toUpperCase()}_VAR2`}
            value={config.VAR2 || ""}
            onChange={(e) => onChange("VAR2", e.target.value)}
          />
        </div>
      </div>
    </div>
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
