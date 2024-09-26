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
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog";
import { SettingsIcon } from "./Icons"; // Add this import

export function RecipesPage() {
  const [deployStatus, setDeployStatus] = useState<{ [key: string]: string }>(
    {}
  );
  const [destroyStatus, setDestroyStatus] = useState<{ [key: string]: string }>(
    {}
  );

  const handleDeploy = async (recipeId: string) => {
    setDeployStatus((prevStatus) => ({
      ...prevStatus,
      [recipeId]: "Deploying...",
    }));

    try {
      const response = await fetch("/api/deploy-recipe", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({ recipeId }),
      });

      const data = await response.json();

      if (data.success) {
        setDeployStatus((prevStatus) => ({
          ...prevStatus,
          [recipeId]: "Deployed",
        }));
      } else {
        throw new Error(data.message || "Failed to deploy recipe");
      }
    } catch (error) {
      console.error("Error deploying recipe:", error);
      setDeployStatus((prevStatus) => ({
        ...prevStatus,
        [recipeId]: "Failed",
      }));
    }
  };

  const handleDestroy = async (recipeId: string) => {
    setDestroyStatus((prevStatus) => ({
      ...prevStatus,
      [recipeId]: "Destroying...",
    }));

    try {
      const response = await fetch("/api/destroy-recipe", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({ recipeId }),
      });

      const data = await response.json();

      if (data.success) {
        setDestroyStatus((prevStatus) => ({
          ...prevStatus,
          [recipeId]: "Destroyed",
        }));
      } else {
        throw new Error(data.message || "Failed to destroy recipe");
      }
    } catch (error) {
      console.error("Error destroying recipe:", error);
      setDestroyStatus((prevStatus) => ({
        ...prevStatus,
        [recipeId]: "Failed",
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
                <BreadcrumbPage>Recipes</BreadcrumbPage>
              </BreadcrumbItem>
            </BreadcrumbList>
          </Breadcrumb>
          <div className="relative ml-auto flex-1 md:grow-0">
            <SearchIcon className="absolute left-2.5 top-2.5 h-4 w-4 text-muted-foreground" />
            <Input
              type="search"
              placeholder="Search recipes..."
              className="w-full rounded-lg bg-background pl-8 md:w-[200px] lg:w-[336px]"
            />
          </div>
        </header>
        <main className="grid grid-cols-1 gap-6 py-6 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4">
          <RecipeCard
            title="Central Data Repository"
            description="Deploy a centralized data storage and management system."
            recipeId="cdr"
            packages={["postgres", "redis"]}
            deployStatus={deployStatus}
            destroyStatus={destroyStatus}
            onDeploy={handleDeploy}
            onDestroy={handleDestroy}
          />
          <RecipeCard
            title="Central Data Repository with Data Warehousing"
            description="Deploy a comprehensive data storage and analytics solution."
            recipeId="cdr-dw"
            packages={["postgres", "redis", "clickhouse"]}
            deployStatus={deployStatus}
            destroyStatus={destroyStatus}
            onDeploy={handleDeploy}
            onDestroy={handleDestroy}
          />
          <RecipeCard
            title="Master Patient Index"
            description="Deploy a system for managing unique patient identifiers across healthcare systems."
            recipeId="mpi"
            packages={["postgres", "redis", "mongo"]}
            deployStatus={deployStatus}
            destroyStatus={destroyStatus}
            onDeploy={handleDeploy}
            onDestroy={handleDestroy}
          />
        </main>
      </div>
    </div>
  );
}

interface RecipeCardProps {
  title: string;
  description: string;
  recipeId: string;
  packages: string[];
  deployStatus: { [key: string]: string };
  destroyStatus: { [key: string]: string };
  onDeploy: (recipeId: string) => void;
  onDestroy: (recipeId: string) => void;
}

function RecipeCard({
  title,
  description,
  recipeId,
  packages,
  deployStatus,
  destroyStatus,
  onDeploy,
  onDestroy,
}: RecipeCardProps) {
  const [isConfigOpen, setIsConfigOpen] = useState(false);
  const [config, setConfig] = useState<{
    [key: string]: { [key: string]: string };
  }>({});

  const handleConfigChange = (
    packageName: string,
    key: string,
    value: string
  ) => {
    setConfig((prevConfig) => ({
      ...prevConfig,
      [packageName]: {
        ...prevConfig[packageName],
        [key]: value,
      },
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
          <DialogContent className="z-50 bg-white">
            <DialogHeader>
              <DialogTitle>Configure {title}</DialogTitle>
            </DialogHeader>
            <ConfigurationForm
              packages={packages}
              config={config}
              onChange={handleConfigChange}
            />
          </DialogContent>
        </Dialog>
        <div className="flex-grow">
          <h3 className="text-lg font-semibold">{title}</h3>
          <p className="text-muted-foreground mt-2">{description}</p>
          <p className="text-sm text-muted-foreground mt-1">
            Recipe ID: {recipeId}
          </p>
        </div>
        <div className="flex gap-2 mt-4">
          <Button
            size="sm"
            onClick={() => onDeploy(recipeId)}
            disabled={deployStatus[recipeId] === "Deploying..."}
          >
            {deployStatus[recipeId] || "Deploy"}
          </Button>
          <Button
            size="sm"
            variant="destructive"
            onClick={() => onDestroy(recipeId)}
            disabled={destroyStatus[recipeId] === "Destroying..."}
            className="ml-auto"
          >
            {destroyStatus[recipeId] || "Destroy"}
          </Button>
        </div>
      </CardContent>
    </Card>
  );
}

interface ConfigurationFormProps {
  packages: string[];
  config: { [key: string]: { [key: string]: string } };
  onChange: (packageName: string, key: string, value: string) => void;
}

function ConfigurationForm({
  packages,
  config,
  onChange,
}: ConfigurationFormProps) {
  return (
    <div className="space-y-4">
      <h4 className="font-medium">Configuration</h4>
      {packages.map((packageName) => (
        <div key={packageName} className="space-y-2">
          <h5 className="text-sm font-medium">{packageName}</h5>
          <div className="flex items-center space-x-2">
            <label className="text-sm font-medium">{`${packageName.toUpperCase()}_VAR1`}</label>
            <Input
              placeholder={`${packageName.toUpperCase()}_VAR1`}
              value={config[packageName]?.VAR1 || ""}
              onChange={(e) => onChange(packageName, "VAR1", e.target.value)}
            />
          </div>
          <div className="flex items-center space-x-2">
            <label className="text-sm font-medium">{`${packageName.toUpperCase()}_VAR2`}</label>
            <Input
              placeholder={`${packageName.toUpperCase()}_VAR2`}
              value={config[packageName]?.VAR2 || ""}
              onChange={(e) => onChange(packageName, "VAR2", e.target.value)}
            />
          </div>
        </div>
      ))}
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

// Remove the old CogIcon function as it's no longer needed
